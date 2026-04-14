# Verify DSP cascade column placement — all DSPs within each dot_core must share the same X coordinate
foreach cell [get_cells -hier -filter {REF_NAME == DSP48E2}] {
    puts "[get_property LOC [get_cells $cell]] -> $cell"
}


-----


