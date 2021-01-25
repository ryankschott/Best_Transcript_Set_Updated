# Best_Transcript_Set_Updated

#Method for running Trinity, then processing results with TransDecoder and InterProscan, then reducing the sequences to a "best" set using cd-hit and some scripts.
#Modified from a script wrote by David Mathog available here: https://github.com/trinityrnaseq/trinity_community_codebase/wiki/Trinity-best-transcript-set
#Requires:
#hmmscan_split.sh - included here
#blastp_split.sh - included here
#TransDecoder - https://github.com/TransDecoder/TransDecoder/wiki
#InterProscan - https://www.ebi.ac.uk/interpro/download/
#HMMER - http://hmmer.org/
#BLAST - ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/
#CD-HIT - http://weizhongli-lab.org/cd-hit/
#DRM-tools - https://sourceforge.net/projects/drmtools/files/
#fastaselecth - ftp://saf.bio.caltech.edu/pub/software/molbio/fastaselecth.c
#match_many.pl - ftp://saf.bio.caltech.edu/pub/software/linux_or_unix_tools/match_many.pl
#You will need to update the paths and files names
