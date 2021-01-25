#Splits the database into pieces based on the number of CPUs you specify and then runs hmmscan on each piece similtaneously
#Usage: bash blastp_split.sh <CPUs> <BLAST Database> <Peptides_fasata>

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
	blastp -query ${PEP}.${ii} -db $REF -max_target_seqs 1 -outfmt 6 -evalue 1e-5 -num_threads 1 > blastp.outfmt6.${ii} 2> blastp.outfmt6.${ii}.log &
	i=$[$i+1]
	printf -v ii "%02d" $i
done

wait

cat >$blastp.outfmt6 <<EOD
EOD

cat >blastp.outfmt6.log <<EOD
EOD

i="0"
ii="00"

while [ $i -lt $CPUS ]
do
	cat blastp.outfmt6.${ii}.log >> blastp.outfmt6.log
	cat blastp.outfmt6.${ii} >> blastp.outfmt6
	i=$[$i+1]
	printf -v ii "%02d" $i
done

NOW=`date`
echo "Finished at $NOW"