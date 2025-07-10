*! version 1.1.0 - General Whipple's Index (state-wise, sex, residence)
program define whippletf
    version 18.0
    syntax [if] [in], ///
        AGEvar(varname) ///
        SEXvar(varname) ///
        STATEvar(varname) ///
        RESIDENCEvar(varname)

    marksample touse, strok
    count if `touse'
    if r(N) == 0 {
        gen byte `touse' = 1
    }

    // Create age_ends_0_5 only if age is between 23 and 62
    tempvar age_ends_0_5
    gen byte `age_ends_0_5' = inlist(mod(`agevar',10),0,5) if inrange(`agevar',23,62) & `touse'

    // Get levels of state, sex, and residence dynamically
    levelsof `statevar' if `touse', local(states)
    levelsof `sexvar' if `touse', local(sexes)
    levelsof `residencevar' if `touse', local(reslist)

    display as text _newline "Whipple's Index Results"
    foreach s of local states {
        foreach sexval of local sexes {
            count if `statevar' == `s' & `sexvar' == `sexval' & inrange(`agevar',23,62) & `touse'
            local total = r(N)
            count if `statevar' == `s' & `sexvar' == `sexval' & `age_ends_0_5' == 1 & `touse'
            local end05 = r(N)

            if `total' > 0 {
                local whip = (`end05' / (0.2 * `total')) * 100
                display as text "State: `s' | Sex: `sexval' | Total - Whipple Index: " ///
                    as result %6.2f `whip'
            }

            foreach resval of local reslist {
                count if `statevar' == `s' & `sexvar' == `sexval' & `residencevar' == `resval' ///
                    & inrange(`agevar',23,62) & `touse'
                local total_sub = r(N)
                count if `statevar' == `s' & `sexvar' == `sexval' & `residencevar' == `resval' ///
                    & `age_ends_0_5' == 1 & `touse'
                local end05_sub = r(N)

                if `total_sub' > 0 {
                    local whip_sub = (`end05_sub' / (0.2 * `total_sub')) * 100
                    display as text "State: `s' | Sex: `sexval' | Residence: `resval' - Whipple Index: " ///
                        as result %6.2f `whip_sub'
                }
            }
        }
    }
end
