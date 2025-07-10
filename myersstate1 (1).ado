program define myersstate1
    version 18.0
    syntax , agevar(name) statevar(name)

    // Check if the specified variables exist
    confirm variable `agevar'
    confirm variable `statevar'

    // Loop over all levels of the state variable
    levelsof `statevar', local(states)

    foreach s of local states {
        di as text "-------------------------------------------------------------"
        di as result "State code: `s'"
        
        preserve
        keep if `statevar' == `s'

        // Prepare age breakdown
        gen terminal = mod(`agevar', 10)
        gen decade_start = floor(`agevar' / 10) * 10

        // Generate 10+a and 20+a groups
        gen group_10a = inlist(decade_start, 10, 30, 50, 70, 90)
        gen group_20a = inlist(decade_start, 20, 40, 60, 80)

        gen col1 = group_10a
        gen col2 = group_20a

        // Collapse to terminal digit
        collapse (sum) col1 col2, by(terminal)
        sort terminal

        // Add weight columns
        gen col3 = _n
        gen col4 = 10 - _n  // 9 to 0

        // Weighted sum
        gen col5 = col1 * col3 + col2 * col4

        // Compute column 6 (percent)
        su col5, meanonly
        scalar total_col5 = r(sum)
        gen col6 = (col5 / total_col5) * 100

        // Compute Myers' Index
        gen dev10 = abs(col6 - 10)
        su dev10, meanonly
        scalar myers_index = r(sum) / 2

        // Final Output
        list terminal col1 col2 col3 col4 col5 col6, noobs sep(0)
        di as result "Myers' Blended Index = " %5.2f myers_index
        
        restore
    }
end
