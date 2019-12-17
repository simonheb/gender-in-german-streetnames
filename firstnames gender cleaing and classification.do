//data from OSM https://www.datendieter.de/item/Liste_von_deutschen_Strassennamen_.csv 
import delimited strassen_osm.txt, encoding(utf8) clear

//minimal data cleaning
replace v1 = lower(subinstr(v1,"-"," ",.))
replace v1 = subinstr(v1,"straße"," straße",.)
replace v1 = subinstr(v1,"weg"," weg",.)
replace v1 = subinstr(v1,"dr. ","",.)
replace v1 = subinstr(v1,"doktor ","",.)
replace v1 = subinstr(v1,"st. ","",.)
replace v1 = subinstr(v1,"graf ","",.)
replace v1 = subinstr(v1,"professor ","",.)
replace v1 = subinstr(v1,"prof. ","",.)
replace v1 = subinstr(v1,"von ","",.)
replace v1 = subinstr(v1,"pfarrer ","",.)
replace v1 = subinstr(v1,"bürgermeister ","",.)
replace v1 = subinstr(v1,"bgm. ","",.)
replace v1 = subinstr(v1,"sankt ","",.)
replace v1 = lower(subinstr(v1,"."," ",.))

//extracting first words, collapsing by frequency
split v1, parse(" ")
gen freq=1
collapse (count) freq (last) v1, by(v11)
sort freq
drop if freq<=2 | freq>=380

//some more cleaning
drop if strpos(" nach Äußerer große alter oberer unterer großer hintere weg gut vordere siedlung innere schloss  grosse burg altstädter industrie  die bad lange kleiner achter vorm unteres krumme gewerbepark vorderer unter  obere kleine untere vor neue beim bei hinter hohe alt zu groß neuer Äußere hinterm unterm klein straße ober rot e drei rue auf'm Über langer der neu de van kurze gewerbegebiet ob grüne hoher breite weiße kloster haupt"," "+v11+" ")
drop if strlen(v11)<3

//restrict to meet gender API limits
keep if freq>=6
gen land="Deutschland"

//export
export delimited using "C:\Users\shess\Downloads\streetnames collapsed.csv", replace

//re-import
import delimited "C:\Users\shess\Downloads\streetnames_collapsed.csv", encoding(utf8) clear
drop if missing(ga_accuracy)

//drop stuff that were no names apparently
drop if ga_accuracy < 80 | (ga_accuracy < 90 & ga_samples <1000) | (ga_accuracy <= 95 & ga_samples <500) | (ga_accuracy <=98 & ga_samples <50)| (ga_samples <20)

collapse (sum) freq, by(ga_gender)

tab freq
di 584/8109*100
