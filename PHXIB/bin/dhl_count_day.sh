#! /bin/sh
## DHL Counts
#
. ./src/count-list-func.sh
#
#base='/home/sagara/bin/'
base='/data/phxib/data/projectbackup/phxib/dhlgf/'
iftmin='alfa_orders/'
iftrin='alfa_iftrin/'
carr_ord='carrier_orders/' 
iod='alfa_iod/'
#set date
day=$(date +'%Y%m%d')
#echo $day
cd $base
#pwd
sleep 120
touch count.txt
time=$(date +'%Y-%m-%d %H:%M:%S')
cont_file=$base'count.txt'
echo $cont_file
if [ -e $cont_file ]
then
rm -rf $cont_file
fi
#echo $time
echo "DHL GF Order Count on $time" >> $cont_file
#Take Order Count
cd $iftmin
#pwd
if [ -d $day ]
then 
cd $day
##########################proceed only if the Direcotory for the day is available ####
#pwd
orders=$(find . -type f | wc -l)
echo "IFTMIN Count= "$orders >> $cont_file
else
orders=0
echo "IFTMIN Count= "$orders >> $cont_file
fi
cd $base
#Take IFTRIN Count
cd $iftrin
#pwd
if [ -d $day ]
then 
cd $day
#pwd
invoice=$(find . -type f | wc -l)
echo "IFTRIN Count= " $invoice >> $cont_file
else
invoice=0
echo "IFTRIN Count= " $invoice >> $cont_file
fi 
cd $base
#Take carrier Order Count
cd $carr_ord
#pwd
if [ -d $day ]
then 
cd $day
#pwd
carr_orders=$(find . -type f | wc -l)
echo "Carrier IFTMIN = " $carr_orders >> $cont_file
else
carr_orders=0
echo "Carrier IFTMIN = " $carr_orders >> $cont_file
fi
cd $base
#Take IOD Count
cd $iod
#pwd
if [ -d $day ]
then
cd $day
#pwd
alf_iod=$(find . -type f | wc -l)
echo "ALFA IOD = " $alf_iod >> $cont_file
else
alf_iod=0
echo "ALFA IOD = " $alf_iod >> $cont_file
fi

#cat $cont_file
#mail -s "DHL GF Message Count per Day $day" cta.alfasupport@ebuilder.com cta.2ndline.int@ebuilder.com < $cont_file
#mail -s "DHL GF Message Count per Day $day" sagara.jayathilaka@ebuilder.com < $cont_file
#
#
echo "" >> $cont_file
echo "" >> $cont_file
echo "" >> $cont_file
echo "I have attached the IDs of IFTMIN, IFTRIN , Carrier IFTMIN and IODs lisy for your reference !!!" >> $cont_file
#
##Generate list
IftminOrders
sleep 2
IftrinInvoice
sleep 2
CarrierIftmin
sleep 2
IOD
#cat $cont_fil
#
mutt -a "/opt/phxib/xib/local/bin/src/iftmin-list.txt" -a "/opt/phxib/xib/local/bin/src/iftrin-list.txt" -a "/opt/phxib/xib/local/bin/src/carrier_iftmin.txt" -a "/opt/phxib/xib/local/bin/src/iod.txt" -s "DHL GF Message Count at 15 CET" sagara.jayathilaka@ebuilder.com < $cont_file
#mutt -a "/opt/phxib/xib/local/bin/src/iftmin-list.txt" -a "/opt/phxib/xib/local/bin/src/iftrin-list.txt" -a "/opt/phxib/xib/local/bin/src/carrier_iftmin.txt" -a "/opt/phxib/xib/local/bin/src/iod.txt" -s "DHL GF Message Count at 15 CET" cta.alfasupport@ebuilder.com cta.2ndline.int@ebuilder.com < $cont_file

