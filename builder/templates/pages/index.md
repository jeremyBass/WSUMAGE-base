{% markdown %}
# WSU Magento parent theme
## Repo : [WSUMAGE-base](https://github.com/washingtonstateuniversity/WSUMAGE-base)
This is a Magento web app repo.  This is loaded in to a server base project such as [https://github.com/washingtonstateuniversity/WSU-Web-Serverbase](https://github.com/washingtonstateuniversity/WSU-Web-Serverbase).  This project may be loaded with other web apps as well, but it's all loaded in with the server base.  A web app can't live without the server.  The steps to get this project up is

1. git clone the server base
	```bash
	$ git clone git@github.com:washingtonstateuniversity/WSU-Web-Serverbase.git wsuweb
	$ cd wsuweb
	```
1. git clone the web app to the app folder
	```bash
	$ git clone git@github.com:washingtonstateuniversity/WSUMAGE-base.git app/store.wsu.edu
	```
1. From the server root folder, just vagrant up and the app will be installed with the
	```bash
	$ vagrant up
	```
1. **NOTE:** If you have your local server up already, including a new app is simple.  All that is needed is to call the highstate for salt from the server.  To do this fallow these steps:
	```bash
	vagrant ssh
	su      #note normally a ssh key is used but the password is 'vagrant'
	salt-call state.highstate env=store.wsu.edu
	```
	From here the app will install and you will be able to start working with the store.

Those are the steps for your local dev environment.  You may also highstate the project on its own, but it must be on a ready server.  That is `salt-call state.highstate env=store.wsu.edu`.
		  
**Note:** More to come. Thank you for reading.

{% endmarkdown %}