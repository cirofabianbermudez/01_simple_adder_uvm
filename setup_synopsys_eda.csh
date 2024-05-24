#!/bin/tcsh

# From /cds/env/setenv_synopsys_2022_23.csh
setenv SYNOPSYS_ROOT /eda/synopsys/2022-23/RHELx86

# Run the corresponding script for each tool
foreach script ( `ls -1 $SYNOPSYS_ROOT/../scripts/*.csh` )
	if ("$script" != "/eda/synopsys/2022-23/RHELx86/../scripts/VIRT-PROTO_2022.06-2_RHELx86.csh") then
		source $script
	endif
end

# Synopsys License
setenv SNPSLMD_LICENSE_FILE 5280@sunba2
setenv SNPS_LICENSE_FILE 5280@sunba2

