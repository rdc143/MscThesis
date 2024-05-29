module load anaconda3/2020.11 udocker/
udocker pull esayyari/discovista

udocker run -v /maps/projects/seqafrica/scratch/rdc143/trag_analyses/astral/DV:/data esayyari/discovista discoVista.py -m 5 -p ./ -a annotation.txt -o results -g waterbuck
