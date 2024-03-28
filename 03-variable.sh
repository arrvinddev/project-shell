a=10
name=DevOps

#Print Variable
echo a = $a
echo name = ${name}

#DATE=2023-04-21
DATE=$(date +%F)
echo Today date is ${DATE}

ARTH=$((2-3*4/2))
echo ARTH = ${ARTH}

#Special Variables for Inputs
echo Script name - $0

echo First Argument - $1

echo Second Argument - $2 

echo All Arguments - $*

echo No of Arguments - $#


