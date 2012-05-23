#!/bin/bash

for algo in weka.classifiers.trees.J48 weka.classifiers.trees.NBTree weka.classifiers.bayes.NaiveBayes weka.classifiers.lazy.KStar
do
    for i in $*
    do
	echo ${algo##*.} ${i%%.*}
	java -Xmx4096m -classpath /usr/share/java/weka.jar $algo -t 3a/$i > 3b/${i%%.*}_${algo##*.}.txt
    done
done