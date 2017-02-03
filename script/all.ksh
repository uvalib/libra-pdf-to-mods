ASSETS=../jt-year2-assets
RESULTS=../results
rm -fr $RESULTS/* > /dev/null 2>&1

TMPFILE=/tmp/assets.$$
rm -fr $TMPFILE > /dev/null 2>&1

task=createmodsforpdf_jefftrust2

find $ASSETS -name *.pdf > $TMPFILE
for f in $(<$TMPFILE); do

   bn=$(basename $f)
   dd=$(basename $(dirname $f))

   rd=$RESULTS/$dd
   mkdir -p $rd > /dev/null 2>&1
 
   ./$task -v $f - > $rd/$bn.out
done

rm -fr $TMPFILE >/dev/null 2>&1
echo "Results in $RESULTS"
exit 0
