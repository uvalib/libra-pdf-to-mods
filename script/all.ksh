#!/usr/bin/env bash
#
#

function exit_on_error {
   local RES=$1
   if [ $RES -ne 0 ]; then
      echo "Terminating with error $RES"
      exit $RES
   fi
   return
}

# the default input assets
INPUT_ASSETS=../jt-year2-assets

# the default output results
OUTPUT_RESULTS=../results

# check argument count
if [ $# -ne 0 ]; then
   if [ $# -ge 1 ]; then
      INPUT_ASSETS=$1
   fi
   if [ $# -ge 2 ]; then
      OUTPUT_RESULTS=$2
   fi
fi

# check for the existance of the input directory
if [ ! -d $INPUT_ASSETS ]; then
   echo "ERROR: $INPUT_ASSETS does not exist or is not readable, aborting"
   exit_on_error 1
fi

echo "Processing input from $INPUT_ASSETS"
echo "Output to $OUTPUT_RESULTS"

# clean the results directory
rm -fr $OUTPUT_RESULTS/* > /dev/null 2>&1

# define the temp file and clean
TMPFILE=/tmp/assets.$$
rm -fr $TMPFILE > /dev/null 2>&1

# define the logfile name and clean
LOGFILE=logfile.log
rm -fr $LOGFILE > /dev/null 2>&1

# the actual conversion task
CONVERSION=createmodsforpdf_jefftrust2

# create the list of files
find $INPUT_ASSETS -name *.pdf > $TMPFILE

# check it is not empty
COUNT=$(wc -l $TMPFILE | awk '{print $1}')
if [ "$COUNT" == "0" ]; then
   echo "ERROR: $INPUT_ASSETS does not contain any PDF files, aborting"
   exit_on_error 1
fi

echo "Processing $COUNT files"

# go through the list of input files
for f in $(<$TMPFILE); do

   # get the interesting parts of the input file name
   bn=$(basename $f)
   dd=$(basename $(dirname $f))

   # define and create the results directory
   rd=$OUTPUT_RESULTS/$dd
   mkdir -p $rd > /dev/null 2>&1

   echo "" >> $LOGFILE
   echo "$f" >> $LOGFILE
   echo -n "."

   # do the conversion and abort if we error 
   ./$CONVERSION -v $f - > $rd/$bn.xml 2>>$LOGFILE
   exit_on_error $?

   # create a sym link of the input asset in the results directory
   FULLNAME=$(realpath $f)
   ln -s $FULLNAME $rd
   exit_on_error $?
done

# cleanup
rm -fr $TMPFILE >/dev/null 2>&1

# give the good news
echo ""
echo "Results available in $OUTPUT_RESULTS"
echo "Logfile available $LOGFILE"

# all over
exit 0

#
# end of file
#
