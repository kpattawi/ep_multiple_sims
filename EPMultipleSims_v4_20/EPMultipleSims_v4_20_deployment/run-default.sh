#!/bin/bash

if [ $# -ne 1 ]; then
    echo "usage: $0 path/to/_generated"
    exit 1
fi

if [ ! -d $1 ]; then
    echo "illegal argument: expected _generated directory"
    exit 1;
fi

root_directory=`pwd`
logs_directory=$root_directory/logs
code_directory=`realpath ${1%/}`

fedmgr_host=127.0.0.1
fedmgr_port=8083

timestamp=`date +"%F_%T"`

function getNumberJoined {
    if (( $# != 1 ))
    then
        echo bad syntax: getNumberJoined federateType
        exit 1
    fi
    federateList=$(curl -s -X GET http://$fedmgr_host:$fedmgr_port/federates -H "Content-Type: application/json")
    # JSON Query:
    #   .[] = process all values in the input object
    #   select(...) = exclude entries for resigned federates (resignTime defined) and federates that are not the desired TYPE
    #   enclosing [ ] = combine the result from the above queries into a single JSON array
    #   length = count the number of elements in the combined array
    echo $federateList | jq --arg TYPE "$1" '[.[] | select(.resignTime == null and .federateType == $TYPE)] | length'
}

function waitUntilJoined {
    if (( $# != 2 ))
    then
        echo bad syntax: waitUntilJoined federateType expectedNumber
        exit 1
    fi
    federateType=$1
    expectedNumber=$2

    if (( $expectedNumber < 1 ))
    then
        echo "illegal argument: expectedNumber of federates cannot be $expectedNumber"
        exit 1
    fi

    printf "Waiting for $expectedNumber instances of $federateType to join.."
    while (( $(getNumberJoined $federateType) != $expectedNumber))
    do
        printf "."
        sleep 5
    done
    printf "\n"
}

nc -z $fedmgr_host $fedmgr_port
if [ $? -eq 0 ]; then
    echo Cannot start the federation manager on port $fedmgr_port
    exit 1
fi

if [ ! -d $logs_directory ]; then
    echo Creating the $logs_directory directory
    mkdir $logs_directory
fi

# run the federation manager
cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/federation-manager-${timestamp}.log -T "Federation Manager" -geometry 140x40+0+30 -e "export CPSWT_ROOT=`pwd` && mvn exec:java -P FederationManager" &

printf "Waiting for the federation manager to come online.."
until $(curl -o /dev/null -s -f -X GET http://$fedmgr_host:$fedmgr_port/fedmgr); do
    printf "."
    sleep 5
done
printf "\n"

curl -o /dev/null -s -X POST http://$fedmgr_host:$fedmgr_port/fedmgr --data '{"action": "START"}' -H "Content-Type: application/json"

# run the other federates
cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Controller-${timestamp}.log -T "Controller" -geometry 140x40+30+60 -e "mvn exec:java -P ExecJava,Controller" &
waitUntilJoined Controller 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Market-${timestamp}.log -T "Market" -geometry 140x40+60+90 -e "mvn exec:java -P ExecJava,Market" &
waitUntilJoined Market 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Reader-${timestamp}.log -T "Reader" -geometry 140x40+90+120 -e "mvn exec:java -P ExecJava,Reader" &
waitUntilJoined Reader 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket0-${timestamp}.log -T "Socket0" -geometry 140x40+120+150 -e "mvn exec:java -P ExecJava,Socket0" &
waitUntilJoined Socket0 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket1-${timestamp}.log -T "Socket1" -geometry 140x40+150+180 -e "mvn exec:java -P ExecJava,Socket1" &
waitUntilJoined Socket1 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket10-${timestamp}.log -T "Socket10" -geometry 140x40+180+210 -e "mvn exec:java -P ExecJava,Socket10" &
waitUntilJoined Socket10 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket11-${timestamp}.log -T "Socket11" -geometry 140x40+210+240 -e "mvn exec:java -P ExecJava,Socket11" &
waitUntilJoined Socket11 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket12-${timestamp}.log -T "Socket12" -geometry 140x40+240+270 -e "mvn exec:java -P ExecJava,Socket12" &
waitUntilJoined Socket12 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket13-${timestamp}.log -T "Socket13" -geometry 140x40+270+300 -e "mvn exec:java -P ExecJava,Socket13" &
waitUntilJoined Socket13 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket14-${timestamp}.log -T "Socket14" -geometry 140x40+300+330 -e "mvn exec:java -P ExecJava,Socket14" &
waitUntilJoined Socket14 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket15-${timestamp}.log -T "Socket15" -geometry 140x40+330+360 -e "mvn exec:java -P ExecJava,Socket15" &
waitUntilJoined Socket15 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket16-${timestamp}.log -T "Socket16" -geometry 140x40+360+390 -e "mvn exec:java -P ExecJava,Socket16" &
waitUntilJoined Socket16 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket17-${timestamp}.log -T "Socket17" -geometry 140x40+390+420 -e "mvn exec:java -P ExecJava,Socket17" &
waitUntilJoined Socket17 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket18-${timestamp}.log -T "Socket18" -geometry 140x40+420+450 -e "mvn exec:java -P ExecJava,Socket18" &
waitUntilJoined Socket18 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket19-${timestamp}.log -T "Socket19" -geometry 140x40+450+480 -e "mvn exec:java -P ExecJava,Socket19" &
waitUntilJoined Socket19 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket2-${timestamp}.log -T "Socket2" -geometry 140x40+480+510 -e "mvn exec:java -P ExecJava,Socket2" &
waitUntilJoined Socket2 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket3-${timestamp}.log -T "Socket3" -geometry 140x40+510+540 -e "mvn exec:java -P ExecJava,Socket3" &
waitUntilJoined Socket3 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket4-${timestamp}.log -T "Socket4" -geometry 140x40+540+570 -e "mvn exec:java -P ExecJava,Socket4" &
waitUntilJoined Socket4 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket5-${timestamp}.log -T "Socket5" -geometry 140x40+570+600 -e "mvn exec:java -P ExecJava,Socket5" &
waitUntilJoined Socket5 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket6-${timestamp}.log -T "Socket6" -geometry 140x40+600+630 -e "mvn exec:java -P ExecJava,Socket6" &
waitUntilJoined Socket6 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket7-${timestamp}.log -T "Socket7" -geometry 140x40+630+660 -e "mvn exec:java -P ExecJava,Socket7" &
waitUntilJoined Socket7 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket8-${timestamp}.log -T "Socket8" -geometry 140x40+660+690 -e "mvn exec:java -P ExecJava,Socket8" &
waitUntilJoined Socket8 1

cd $root_directory
xterm -fg white -bg black -l -lf $logs_directory/Socket9-${timestamp}.log -T "Socket9" -geometry 140x40+690+720 -e "mvn exec:java -P ExecJava,Socket9" &
waitUntilJoined Socket9 1

# terminate the simulation
read -n 1 -r -s -p "Press any key to terminate the federation execution..."
printf "\n"

curl -o /dev/null -s -X POST http://$fedmgr_host:$fedmgr_port/fedmgr --data '{"action": "TERMINATE"}' -H "Content-Type: application/json"

printf "Waiting for the federation manager to terminate.."
while $(curl -o /dev/null -s -f -X GET http://$fedmgr_host:$fedmgr_port/fedmgr); do
    printf "."
    sleep 5
done
printf "\n"

