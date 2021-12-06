##\bin\bash

## 2021.12.06 - Baptiste CHAPPE
## Script pour calculer la plus value/moins value depuis un csv Révolut.

REP="/opt/revolut"
CSV="${REP}/all-statements.csv"
LIST="${REP}/listaction.csv"
OUTPUT="${REP}/declartion.csv"

while IFS="," read -r col1 ## Lecture de la col1
    do 
        VAR="$col1" ## Variable sur col1
        SED=$(sed -n "/$VAR/p" $CSV) ## Chaque ligne du fichier parsé utilise le détermiant unique. 
        echo "$SED" > ${REP}/output/$VAR.txt ## Extract de l'ensemble des lignes contenant le détermiant unique
        grep "DIV" ${REP}/output/$VAR.txt > ${REP}/output/$VAR.DIV.txt ## Extract du DIVIDANDE
        grep "SELL" ${REP}/output/$VAR.txt > ${REP}/output/$VAR.SELL.txt ## Extract de la vente (SELL)
        grep "BUY" ${REP}/output/$VAR.txt > ${REP}/output/$VAR.BUY.txt ## Extract de la partie achat
        VBUY=$(cut -d ';' -f 10 ${REP}/output/$VAR.BUY.txt | xargs | sed -e 's/\ /+/g' | sed -e 's/\,/./g') ## Remplacement des espaces par + remplacement . pour les ,
        VDIV=$(cut -d ';' -f 10 ${REP}/output/$VAR.DIV.txt | xargs | sed -e 's/\ /+/g' | sed -e 's/\,/./g') ## Remplacement des espaces par + remplacement . pour les ,
        VSELL=$(cut -d ';' -f 10 ${REP}/output/$VAR.SELL.txt | xargs | sed -e 's/\ /+/g' | sed -e 's/\,/./g') ## Remplacement des espaces par + remplacement . pour les ,
        echo -n "$VAR," >> $OUTPUT
        BC=$(echo "$VSELL + $VDIV - $VBUY" | bc) ## Calcul du prix de vente + le dividande - le prix d'achat
        echo "$BC" >> $OUTPUT ## Export dans le fichier OUTPUT/Déclaration.csv
done < ${LIST} #fin de la boucle
OUT1=$(cut -d ',' -f2 $OUTPUT | sed '/^$/d')
OUT2=$(echo "$OUT1")
echo $OUT2 | sed -e 's/\ /+/g' | bc >> ${OUTPUT} ## Calcul total de la PV.
