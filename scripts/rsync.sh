#

subject=("sub-0002" "sub-0003" "sub-0004" "sub-0005" "sub-0006" \
"sub-0010" "sub-0011" "sub-0013" "sub-0014" "sub-0015" "sub-0017" "sub-0020")
for SUB in ${subjects[*]};do
# does folder exist? /Volumes/seagate/spacetop/derivatives/dartmouth/fmriprep/${SUB}
mkdir -p /Volumes/seagate/spacetop/derivatives/dartmouth/fmriprep/${SUB}
rsync -aP f0042x1@discovery.dartmouth.edu:/dartfs-hpc/rc/lab/C/CANlab/labdata/data/spacetop/derivatives/dartmouth/fmriprep/fmriprep/${SUB}/ /Volumes/seagate/spacetop/derivatives/dartmouth/fmriprep/${SUB}
done
