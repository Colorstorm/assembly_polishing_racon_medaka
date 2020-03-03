#!/bin/bash
# Fabian Friedrich, Dec 2019
# Colin Davenport Mar 2020
# Requires miniconda repository ont with medaka, minimap and racon
# Usage: sbatch run_polish_pipe_SLURM.sh nanopore_reads.fastq contigs.fasta

# set partition
#SBATCH -p normal

# set run on bigmem node only
#SBATCH --mem 480g

# set run on bigmem node only
#SBATCH --cpus-per-task 8

# share node
#SBATCH --share

# set max wallclock time
#SBATCH --time=47:00:00

# set name of job
#SBATCH --job-name=polish


echo "run_polish_pipe_SLURM.sh"
echo "Input reads as fastq - FAST5 not required: " $1
reads=$1
echo "Input contigs as fasta: " $2
ctg=$2


#Output directory
outdir='polished'

#temporary path for overlapping file
tmpovl='tmp.ovl.paf'

# Add miniconda3 to PATH
. /mnt/ngsnfs/tools/miniconda3/etc/profile.d/conda.sh

# Activate env on cluster node
#conda activate ont2
#conda env update -f /mnt/ngsnfs/conda_envs/env.polishing.yml
conda activate polishing


# Run script

# Fail completely if a stage fails - failing ?	
#set -euxo pipefail

#Polishing iterations
maxiter=2
# cpu threads
threads=8

# Setup initial contig files safely
cp $ctg tmp.0.fasta


echo '#################################################'
echo 'Starting Minimap and Racon'
echo '#################################################'


#Minimap and Racon
for ((i=1; i<=$maxiter; i++))
do
	echo '#################################################'
	echo 'Minimap round: ' $i
	echo '#################################################'
	h=$(expr $i - 1)

	# updated git cloned minimap2 2020 March
	/mnt/ngsnfs/tools/minimap2/minimap2/minimap2 -x map-ont -t $threads tmp.$h.fasta  "$reads" > $tmpovl

	#conda minimap
	#minimap2 -x map-ont -t $threads tmp.$h.fasta  "$reads" > $tmpovl

	echo '#################################################'
	echo 'Racon round: ' $i
	echo '#################################################'

	racon -t $threads "$reads" $tmpovl tmp.$h.fasta > tmp.$i.fasta

	#rm tmp.$h.fasta
done

echo '#################################################'
echo 'Finished Minimap and Racon'
echo 'Starting Medaka'
echo '#################################################'

#Medaka
medaka_consensus -i "$reads" -d tmp.$maxiter.fasta -o $outdir -t $threads

echo '#################################################'
echo 'Finished Medaka'
echo '#################################################'


#Rename results of Minimap and Racon
#mv tmp.$maxiter.fasta $ctg.$maxiter.rac.fasta

#Clean Minimap and Racon up
rm tmp.ovl.paf


echo '#################################################'
echo 'Everything has finished'
echo '#################################################'

