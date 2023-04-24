#!/bin/bash
function usage() {
    echo "Usage: $0 N D";
    echo "       N number of processes";
    echo "       D Delay in mutex";

}

if [ $# -eq 1 ]; then
    N=$1
    D=10
elif [ $# -eq 2 ]; then
    N=$1
    D=$2
else
    usage
    exit 1
fi

echo "system:fischer_"$N"_"$D"_processes"
echo ""

for (( i=0; i<=$N; i++ ))
do
 echo "event:id_is_$i"
done

echo "event:id_to_0"

for (( i=1; i<=$N; i++ ))
do
 echo "event:id_to_$i"
done

echo ""

for (( i=1; i<=$N; i++ ))
do
 echo "clock:timer:t1$i"
 echo "clock:timer:t2$i"
 
done

echo ""

for (( i=1; i<=$N; i++ ))
do
<<comment
 echo "process:proc$i
location:proc$i:sleep{initial:}
location:proc$i:req{}
location:proc$i:wait{}
location:proc$i:cs{}
edge:proc$i:sleep:req:id_is_0{{ provided:; do:t1$i=-$D,t2$i; provided: t2$i<-$D;}}
edge:proc$i:req:wait:id_to_$i{{ provided:; do:t1$i;}}
edge:proc$i:wait:req:id_is_0{{ provided:; do:t1$i=-$D,t2$i; provided: t2$i<-10;}}
edge:proc$i:wait:cs:id_is_$i{{ provided:t2$i==0; do:t2$i;}}
edge:proc$i:cs:sleep:id_to_0{{ }}
"
comment

echo "process:proc$i
location:proc$i:sleep{initial:}
location:proc$i:req{}
location:proc$i:wait{}
location:proc$i:cs{}
edge:proc$i:sleep:req:id_is_0{{ provided:; do:t1$i=-$D;}}
edge:proc$i:req:wait:id_to_$i{{ provided:; do:t1$i,t2$i; provided: t2$i<-$D;}}
edge:proc$i:wait:req:id_is_0{{ provided:; do:t1$i=-$D,t2$i;}}
edge:proc$i:wait:cs:id_is_$i{{ provided:t2$i==0; do:t2$i;}}
edge:proc$i:cs:sleep:id_to_0{{ }}
"
done

echo ""

echo "process:id
location:id:id0{initial:}"

for (( i=1; i<=$N; i++ ))
do
	echo "location:id:id$i{}"
done

echo ""
for (( i=0; i<=$N; i++ ))
do
	for (( j=0; j<=$N; j++ ))
	do
		if (( $i==$j )); then
		    echo "edge:id:id$i:id$i:id_is_$i{{ }}"
		else
		    echo "edge:id:id$i:id$j:id_to_$j{{ }}"
		fi
	done
	echo ""
done


for (( i=1; i<=$N; i++ ))
do
echo "sync:proc$i@id_is_0:id@id_is_0"
done

for (( i=1; i<=$N; i++ ))
do
	echo "sync:proc$i@id_to_0:id@id_to_0"
done


echo " "

for (( i=1; i<=$N; i++ ))
do
	echo "sync:proc$i@id_to_$i:id@id_to_$i"
	echo "sync:proc$i@id_is_$i:id@id_is_$i"

done
