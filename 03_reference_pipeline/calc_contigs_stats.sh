#!/bin/bash

# empties file
> contigs_stats.txt
# for each sample, count number of non-N characters, then count number of loci retained.
# prints sample name, characters, locus count, and mean non-N locus length
for i in $(cat ../sample_list)
do
    x=$(grep -v '^>' consensus/${i}.fa | sed 's/N//g' | wc -c)
    y=$(grep '^>' consensus/${i}.fa | wc -l)
    paste <(echo $i) \
          <(echo $x) \
          <(echo $y) \
          <(echo "${x}/${y}" | bc)
done
