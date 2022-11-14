#!/bin/bash

function lm_traverse_dir(){
	#for file in $(ls $1)		
    for file in `ls $1`       	
    do
        if [ -d $1"/"$file ]  	
        then
            lm_traverse_dir $1"/"$file	
        else
            if [ "${file: -4}" == ".sol" ]
            # if [ "${file: -10}" == ".fixed.sol" ]
            then
                effect_name=$1"/"$file		
                solc $effect_name >> log_tmp.txt 2>&1

                if [ $? == 1 ]
                then
                    echo $effect_name
                fi
            fi
        fi
    done
}


lm_traverse_dir $1

read -p "press enter end"
