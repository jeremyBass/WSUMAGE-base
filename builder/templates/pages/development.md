{% markdown %}
# WSU Magento development Environment

<article>
	<h1 class="header">WSU Magento development guide</h1>
	<div class="wrapper markdown-body">
		<h2 class="header">How to do development</h2>
		<p>There is an ideal way to development for Magento against the WSUMAGE-base repo.  First you must load the project up under the WSU-Web-Serverbase repo.  This will give you a copy of the production version of the site through a local development area.  This area is a Vagrant controlled a headless VirtualBox.  Once this project is loaded with in the serverbase, you will be able to push changes to this local live site.</p>
	</div>
	
	<section>
		<a name="#devModsLoaded"></a>
		<h3>Extensions loaded for Magento in Development</h3>
		<p>There are many extensions that are loaded for production, and you may <a href="/WSUMAGE-base/production.html#productionModsLoaded">see them here</a>.  The listed extensions loaded in the development environment are used to ease your requirements to produce an extension.</p>
		<p>Plugins Loaded:</p>
		<ol>
			<li><a href="https://github.com/jeremyBass/Aoe_Profiler.git">Aoe_Profiler</a></li>
			<li>Coming soon: Script Debugger</li>
		</ol>
	</section>
</article>


**Note:** More to come. Thank you for reading.

{% endmarkdown %}