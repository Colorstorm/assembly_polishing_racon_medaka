# assembly_polishing_racon_medaka
Slurm-pipeline to polishing assemblies with nanopore reads.

The assemblies will be polished with [racon](https://github.com/lbcb-sci/racon) and [medaka_consensus](https://github.com/nanoporetech/medaka)

Default are two itterations of minimap to generate the overlaps and racon to polish the assembly followed by one time medaka.

## Usage
```
sbatch run_polish_pipe_SLURM.sh <reads.fastq> <assembly.fasta>
```
