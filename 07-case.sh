fruit=$1

case $fruit in 
  apple)
  echo Price- 10$
  ;;
  banana)
  echo Price - 0.2$
  *)
  echo fruit not found
  ;;
esac

# execution  
# bash 07-case.sh apple   
# bash 07-case.sh banana
# we dont prefer case condition, limitation is string comparision only case can do, cant deal with arithmetic or file comparsion
 
 
 