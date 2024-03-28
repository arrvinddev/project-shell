
#Declare a function 

function_name () {
   echo Hello world
}

# Call a function 

function_name

#We can send inputs to the function and access them with special variables $1-$n, $*,$#

function_name1()
{
   a =234 #local scope
   echo first argument = $1 
   echo second argument = $2 
   echo all arguments = $*
   echo no of arguments = $#
}

function_name1 123 xyz

a =123 #global scope 

function_name2() { 
   echo Hello
   return 1 
   # 1 is a exit status and it ranges from 0 -255
}

function_name2
echo Exit status of function - $?
