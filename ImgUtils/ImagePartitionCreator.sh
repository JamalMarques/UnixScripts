#!/bin/bash

WORKING_DIRECTORY="./temp"
DEFAULT_MOUNTING_POINT="./mnt"
DEF_BS=4096

show_help ()
{
	echo "TODO!"
	echo "You wanna know how to run it? read the code until next release :)"
}

mount_image ()
{
	#$1 Filename
	#$2 Extesion
	#$3 MountPoint 

	if [[ -f $3 ]]
	then
		rm -r $3
	fi

	mkdir $3
	echo "Mounting..."
	sudo mount -t $2 -o loop $1 $3
	echo "Mount Succeed.."
}

umount_image ()
{
	#$1 MountedPoint

	echo " "
	echo "Umounting image..."
	if [[ -f $1 ]]
        then
           	echo "File mounted not found..."
		exit 1
        fi

        sudo umount $1
	rm -r $1
        echo "Umounted Succeed.."
}

create_empty_image ()
{
	#$1 FileName
	#$2 FileSize (bytes)
	#$3 Destination

	tempFileNamePath="$3/$1-temp.img"

	echo "Creating image of [ $(( $2 / ${DEF_BS} )) ] blocks in destination \"${tempFileNamePath}\"" >&2
	dd if=/dev/zero bs=${DEF_BS} count=$(( $2 / ${DEF_BS} )) of="${tempFileNamePath}" >&2

	mkfs.ext4 ${tempFileNamePath} >&2

	echo "${tempFileNamePath}"
}

fill_image_with_data ()
{
	#$1 MountedPoint
	#$2 DataType (0=zero,1=one,2=rand)

	echo " "
	
	destination="$1/data.dat"
	dataType="/dev/zero"

	case "$2" in
		0|2)
			if [ $2 = 0 ]
			then
				echo "Creating internal data using zero"
				dataType="/dev/zero"
			else
				echo "Creating internal data using random"
				dataType="/dev/urandom"
			fi

			echo "Creating internal data using  blocks in destination \"${destination}\"" >&2
			sudo dd if=${dataType} bs=${DEF_BS} of="${destination}" >&2
			;;
		1)
                        echo "Creating internal data using one"
			echo "Creating internal data using  blocks in destination \"${destination}\"" >&2
			sudo tr '\0' '\377' < /dev/zero | sudo dd bs=${DEF_BS} of="${destination}" >&2
                        ;;
	esac

	echo "Internal data created..."
}

transform_to_sparse () 
{
	#$1 Filename
	#$2 FilenameFinal
	echo " "
	echo "Transforming into sparse..."

	img2simg $1 $2 >&2

	echo "Done."
}

remove_temp ()
{
	echo " "
	echo "Removing temp data..."
	rm -r ${WORKING_DIRECTORY}
	echo "Done."
}

starting_point ()
{
	#$1 FileName
	#$2 PartitionSize (bytes)
	#$3 DataType (0=zero,1=ones,2=rand)
	echo "Executing $0..."
	
	echo "Creating Working directory..."
	mkdir $WORKING_DIRECTORY

	echo "Creating Image..."
	echo " "
	tempFileName=$(create_empty_image $1 $2 $WORKING_DIRECTORY)

	mount_image ${tempFileName} ext4 ${DEFAULT_MOUNTING_POINT}

	fill_image_with_data ${DEFAULT_MOUNTING_POINT} $3

	umount_image ${DEFAULT_MOUNTING_POINT}

	transform_to_sparse ${tempFileName} "$1.img"

	remove_temp

	echo "Process completed file created with name $1.img"
}


##
# Main
##
case "$1" in
	-h|--help)
		show_help
		exit 0
		;;
	-f|--file)
		starting_point $2 $3 $4
		exit 0
		;;
esac
