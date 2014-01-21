WSUMAGE-base
============

This is a Magento web app repo.  This is loaded in to a server base project such as https://github.com/washingtonstateuniversity/WSU-Web-Serverbase .  This project may be loaded with other web apps as well, but it's all loaded in with the server base.  A web app can't live without the server.  The steps to get this project up is 

1. git clone the server base 

      > `$ git clone git@github.com:washingtonstateuniversity/WSU-Web-Serverbase.git devserver`
      
1. git clone the web app to the www folder 

      > `$ cd devserver/www`
      
      > `$ git clone git@github.com:washingtonstateuniversity/WSUMAGE-base.git store.wsu.edu`
      
1. get back to the server root and start

      > `$ cd ../`
      
      > `$ vagrant up`
      
Those are the steps for your local dev environment.  You may also highstate the project on its own, but it must be on a ready server.  That is `salt-call state.highstate env=store.wsu.edu`. 

More will come.  Thank you for reading.
