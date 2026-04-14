# Custom RTL CNN Inference Accelerator — Kria KV260

## Overview

Ongoing project; building rtl and hardware/software stack piece by piece as I learn. I aim to use my custom weight-stationary compute engine with sliding window convolution dataflow on variable-size 16-bit fixed-point arrays.

So far: MVM engine is done! (Met timing at 500MHz).

## What's Done

### Manual DSP and BRAM primitive instantiation

One of the main things I considered while working on this was maximizing performance through making synthesis behaviour as predictable as possible and using native FPGA fabric resources. That included *instantiating both memory and DSP macros manually.*

![DSP cascade architecture](dsp_cascade.png)
*Typical approach: parallel DSPs with fabric adder tree vs this implementation: cascaded DSP MAC chain*

A typical MVM approach separates multiplication (DSP slices) and accumulation (LUT-based adder tree), I combined both stages into cascaded DSP chains using PCIN/PCOUT. Three biggest differences:

**Routing:** DSP slices sit in columns in UltraScale+ with dedicated native interconnect between them. Accumulation through PCIN/PCOUT uses that path; no general-purpose fabric routing. Verified post-implementation that all DSPs per compute instance landed on the same column without Pblock constraints.

**Latency:** An adder tree adds ⌈log₂(N)⌉ extra pipeline stages on top of DSP multiply latency. PCIN/PCOUT folds accumulation into the chain itself; latency is fixed at N DSP stages, each contributing 4 cycles internally. Tradeoff is that longer cascades mean more cycles to first result, but dedicated routing makes higher frequencies achievable.

**Utilization:** Almost exclusively DSP slices; no LUTs burned on adder tree logic.

Worth noting: whether the cascade beats an adder tree depends on kernel size. For very large vectors an adder tree might win on latency. But larger matrices also give you more cycles before the next matrix load, which naturally absorbs the extra pipeline fill time. A future optimization would be a mux between both approaches based on vector width.

---

### Data dependency hazard handling

A major difference between adder tree and PCIN/PCOUT accumulation is data dependency. For maximum throughput you want a new valid result every cycle after initial pipeline fill; each valid set of data should stay in registers for exactly one clock cycle and continuously move down the pipeline.

The problem: accumulation happens at the 3rd stage of the DSP pipeline. So DSP #1 (which should output first + second partial sums) needs its input delayed by one cycle so it arrives at the accumulation stage exactly when PCOUT arrives from DSP #0. By the same logic, the ith DSP along the cascade needs its input delayed by i cycles.

Fixed with a VEC_W x VEC_W shift register queue; each operand pair gets staggered into its DSP at the correct cycle offset. This dependency hazard doesn't exist with an adder tree since all DSP instances output simultaneously and feed into fully parallel independent data lanes.

---

### Sliding window convolution dataflow

Instead of feeding partial vector x vector operands, the engine feeds accumulated matrices; a full weight matrix row per cycle in steady state. This wasn't planned upfront; it emerged naturally. Weights persist in BRAM across activations, and sliding one new weight row per cycle while the activation stays fixed produces consecutive MVM results for overlapping weight windows. That's structurally identical to a convolution kernel sliding across input data. No architectural changes needed; the engine just was convolution.

This increases DSP usage compared to a vector-only approach but gives much more detailed convolution for image processing with one result per cycle in steady state after pipeline fill.

---

### RAMB36E2 explicit instantiation

Activation and weight BRAMs instantiated directly from UG573 in Simple Dual-Port mode; write port A, read port B, 72-bit width for maximum bandwidth. Explicit instantiation prevents distributed RAM inference.

Things that aren't obvious from the template:
- SDP assigns port A as write and port B as read
- 72-bit width spreads the data bus across DOUTADOUT and DOUTBDOUT combined
- DOB_REG=1 adds a latency cycle the FSM has to absorb
- REGCEB must be tied high or data won't clock through the output register

Result BRAM uses CLOCK_DOMAINS("INDEPENDENT"); PL writes on the compute clock, PS reads on its own clock when PS integration arrives.

---

### Timing closure at 500MHz

Met timing at 500MHz with 0.234ns slack! (VEC_W = 16 => 16 x 16 = 256 DSP slices)
I used `dont_touch` rtl attributes on the shift register queue array declarations inside the compute primitive, and also on unused bram ports, as without them Vivado traces them as unobservable/unused and prunes them. 

![timing](timing.png)

Final implementation uses 131K flip-flops confirmed in utilization post-fix. Probably some room for optimization here; having synchronous reset may be preventing Vivado from mapping registers to SRLs. Holding off on that until PS integration since it would change synthesis behavior anyway (as most 'dont_touch's would be gone).

- [Utilization report](reports/mvm_pl_top_utilization_placed.rpt)
- [Timing summary report](reports/mvm_pl_top_timing_summary_routed.rpt) 



---

## What's In Progress

**PL side:**
- Bias addition into the DSP MAC datapath
- Splitting weight memory into multiple BRAM instances, one per matrix row, to decouple memory lanes and maximize read bandwidth

**PS-PL integration:**
The meaningful way to test this on the SoC is through DDR DMA; streaming weights and activations from PS-side memory over AXI. Still studying the DMA flow before implementing.

**CNN architecture:**
How many layers, how many running in parallel, what kernel sizes; decisions that depend on how the architecture evolves as I go.

## Architecture Notes


## References
- UG573; UltraScale Architecture Memory Resources User Guide
- UG574; UltraScale Architecture DSP Slice User Guide
- Arora et al., 2022; "Tensor Slices: FPGA Building Blocks for the Deep Learning Era" https://dl.acm.org/doi/full/10.1145/3529650