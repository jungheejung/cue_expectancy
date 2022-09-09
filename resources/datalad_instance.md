
# datalad address
The SpaceTop BIDS datalad should be fetched directly from Discovery. 
THe Discovery directory for the dataset is: `/dartfs/rc/lab/D/DBIC/DBIC/archive/BIDS/Wager/Wager/1076_spacetop`


# setting datalad on a remote machine
## 1. USE a fresh install of datalad on a different machine 
— see [HOW TO INSTALL DATALAD](http://handbook.datalad.org/en/latest/intro/installation.html)
## 2. CONFIRM that there is a recent version of git-annex
Installing Datalad may have installed git-annex, but to check the version of git-annex, run:
```
[JHU-computer]$ git-annex version
git-annex version: 8.20211118-g5a7f25397
```

* The output of ‘git-annex version’ above shows the version date as 20211118; i.e, 2021/11/18 - Nov 18, 2021
* If git-annex version is from 2020 or older, then it should be updated. GIT-ANNEX INSTALL

## 3. UPDATE git-annex version on Discovery
Log onto Discovery and run:
```
[discovery]$ echo 'export PATH=/dartfs/rc/lab/D/DBIC/DBIC/archive/git-annex/usr/bin/:$PATH' >> ~/.bash_profile
```
This adds a line to the `.bash_profile` which adds a path to a working git-annex version to your `$PATH` shell variable whenever you log on to Discovery. 

## 4. INSTALL datalad instance on remote machine
```
$ spctop=/dartfs/rc/lab/D/DBIC/DBIC/archive/BIDS/Wager/Wager/```
1076_spacetop
$ cd ${path_to_local_data_repo}
$ datalad install f00689r@discovery7.dartmouth.edu:${spctop}
```

This will prompt for P’s password, and then should install the dataset, and when done, you should see this:

```
$ ls 1076_spacetop
1076_spacetop
$
```

* This directory contains the clone of the dataset directory structure, text files, meta-data files, and empty data-filename-symlinks to null data files. The entire thing should only take up a couple hundred megabytes on the local storage.

* The entire 1076_spacetop dataset with data files takes up 1.7 Terabytes on Discovery. To get the data files use the datalad get command.

* The datalad commands `get` and `drop` can be used to copy and delete, respectively, contentful data files. 

To get the data for a single subject (e.g., sub-0001):
```
$ datalad get sub-0001
```

To get data for all subjects:
```
$ datalad get sub-*
```