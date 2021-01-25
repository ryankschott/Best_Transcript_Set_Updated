#Splits the Pfamm database into pieces based on the number of CPUs you specify and then runs hmmscan on each piece similtaneously
#Usage: bash hmmscan.sh <CPUs> <Pfam-A.hmm> <longest_orfs.pep>

CPUS=$1
REF=$2
PEP=$3
PEPNAME=$(basename "${PEP%.*}")
PEPEXT=$(basename "${PEP##*.}")
i="0"
ii="00"
echo "Using "$CPUS" CPUS"
echo "PEP = ${PEP}"
echo "PEPNAME = ${PEPNAME}"
echo "PEPEXT = ${PEPEXT}"

if [ -f ${PEP}.$[CPUS-1] ]
then echo "Query Already Split, skipping..."
else
echo "Splitting"
pyfasta split -n $CPUS $PEP
fi

while [ $i -lt $CPUS ]
do
	hmmscan --cpu 1 --domtblout ${PEPNAME}_pfam_out.$ii $REF ${PEP}.${ii} 2> ${PEPNAME}_pfam.${ii}.log 1>&2 &
	i=$[$i+1]
	printf -v ii "%02d" $i
done

wait

cat >${PEPNAME}_pfam_out.txt <<EOD
EOD

cat >${PEPNAME}_pfam.log <<EOD
EOD

i="0"
ii="00"

while [ $i -lt $CPUS ]
do
	cat ${PEPNAME}_pfam.${ii}.log >> ${PEPNAME}_pfam.log
	cat ${PEPNAME}_pfam_out.${ii} >> ${PEPNAME}_pfam_out.txt
	i=$[$i+1]
	printf -v ii "%02d" $i
done

NOW=`date`
echo "Finished at $NOW"