#!/bin/bash
#echo "This script does Stackato setup related to filesystem."
#echo "This script also handles Drupal Setup."

FS=$STACKATO_FILESYSTEM
SAR=$STACKATO_APP_ROOT
DRUSH=http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz

if ! [ -s $HOME/index.php ]
  then
    # download required files
    echo "Downloading Drush and Amani..."
    git clone https://github.com/drush-ops/drush.git $SAR/drush
    #curl -sfS $DRUSH | tar xzf -
    #mv drush $SAR
    git clone -v https://github.com/PeaceGeeks/amani.git

    # I broke the symlink when I moved the repo to my machine
    rm amani/core/profiles/amani
    # Must run drush within the Core folder
    echo "Migrating drupal core into application root..."
    mv amani/core/* amani/core/.??* $HOME

    echo "Link Amani profile to core drupal"
    mv amani/amani profiles/
    #ln -s profiles/amani amani/amani

    # create folders in the shared filesystem
    mkdir -p $FS/sites

    echo "Migrating data to shared filesystem..."
    cp -r sites/* $FS/sites

    echo "Symlink to folders in shared filesystem..."
    #rm -fr sites
    ln -sf $FS/sites sites

fi

# allow custom profile installations (if exist)
if [ -s custom-profile.sh ]
  then
    bash custom-profile.sh
fi

ls $FS
if ! [ -e $FS/INSTALLED ]
  then
    echo "Installing Drupal..."
    #$SAR/drush/drush site-install -y --db-url=$DATABASE_URL amani --account-name=admin --account-pass=passwd --site-mail=it@peacegeeks.org
    $SAR/drush/drush si -y --db-url=$DATABASE_URL amani





    # Drupal successfully installed
    touch $FS/INSTALLED
fi

echo "All Done!"
