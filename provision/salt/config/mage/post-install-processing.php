<?php
ob_start();

//note this is all just free wheel atm and needs to be refactored big time.
//just saying
//also it requires that you have the storeutilities ext installed.

/*
NOTE that this requires
	:: storeutilities
	:: fastsimpleimport
*/

//just as a guide, no real purpose
echo getcwd() . " (working from)\n";
/*$argv = $_SERVER['argv'];*/


include_once('staging/install-config.php');

//exit();die();
//set up the store instance
require_once "app/Mage.php";
umask(0);
Mage::app();
Mage::app()->getTranslator()->init('frontend');
Mage::getSingleton('core/session', array('name' => 'frontend'));
Mage::registry('isSecureArea'); // acting is if we are in the admin
Mage::app('admin')->setUseSessionInUrl(false);
Mage::getConfig()->init();

$SU_Helper = Mage::helper('storeutilities/utilities');

/**
 * Get the resource model
 */
$resource = Mage::getSingleton('core/resource');

/**
 * Retrieve the read connection
 */
$readConnection = $resource->getConnection('core_read');

/**
 * Retrieve the write connection
 */
$writeConnection = $resource->getConnection('core_write');

// switch off error reporting
error_reporting ( E_ALL & ~ E_NOTICE );

$cDat = new Mage_Core_Model_Config();


$cDat->saveConfig('admin/url/custom', ADMIN_URL, 'default', 0);
$cDat->saveConfig('web/unsecure/base_url', UNSECURE_BASE_URL, 'default', 0);
$cDat->saveConfig('web/secure/base_url', SECURE_BASE_URL, 'default', 0);

foreach($_GLOBAL['STORES'] as $store){
	echo "Starting the store by store setting updates\n";
	$i=0;
	foreach (glob("staging/stores/".$store."/settings/*.config") as $filename) {
		$settingsarray = $SU_Helper->csv_to_array($filename);
		foreach($settingsarray as $item){
			$val =  $item['value']=="NULL"?NULL:$item['value'];
			$cDat->saveConfig($item['path'], $val, 'default', 0);
			$i++;
		}
	}
	echo "updated ".$i." settings for store ".$store."\n";
	$stage_file = "staging/".$store."/state.php";
	if(file_exists($stage_file)){
		echo "initalized the store ".$store."'s class\n";
		include_once($stage_file);
	}else{
		echo "There was no stage class to initalize\n";
	}
}





if(SAMPLE_STORE){

	echo "Applying the default multi-store setup\n";


	$defaultCmsPage = '
	<div class="row main-ad-block">
		{CMShtml}
		<div style="clear: both;"></div>
	</div>
	<div class="row ">
		<div class="column twelve-twelfths">
			{{block type="tag/popular" template="tag/popular.phtml"}}
		</div>
	</div>
	<div class="row ">
		<div class="column nine-twelfths home-spot">
			<h1>Sites in the center</h1>
			{{block type="catalog/product" stores_per="5" products_per="2" panles_per="3" template="custom_block/site_list.phtml"}}
		</div>
		<div class="column three-twelfths">
			<p class="home-callout"><a href="{{store direct_url="#"}}"> <img src="{{storemedia url="/feature_store_ad.jpg"}}" alt="" border="0" /> </a></p>
		</div>
	</div>';




	$newRootCat = $SU_Helper->make_category("Student store root");
	if($newRootCat>0){
		$SU_Helper->reparentCategory($newRootCat,22);
		$siteId = $SU_Helper->make_website(array('code'=>'studentstore','name'=>'Student store'));
		if( $siteId>0 ){
			$storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Student Store'), 'student.store.'.BASEURL.'', $siteId, $newRootCat );
			if( $storeGroupId>0 ){
				$storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'studentstore','name'=>'base default veiw') );
				if( $storeId>0 ){
					$SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
					$storeCmsLayouts = array(
						'col1'=>array(
							'twelfths'=>'seven-twelfths',
							'blocks'=>array(
								'blocktop'=>'<a href="{{store direct_url="#"}}"> <img src="{{storemedia url="/lefttop_ad_block.jpg"}}" alt="" border="0" /> </a>',
								'blockbottom'=>'<img src="{{storemedia url="/rightbottom_ad_block.jpg"}}" alt="" border="0" />'
							)
						),
						'col2'=>array(
							'twelfths'=>'five-twelfths',
							'blocks'=>array(
								'blocktop'=>'<img src="{{storemedia url="/trasparent-placeholder-missing-image.png"}}" alt=""  border="0" />',
								'blockbottom'=>'<img src="{{storemedia url="/trasparent-placeholder-missing-image.png"}}" alt=""  border="0" />'
							)
						)
					);
					$CMShtml="";
					foreach($storeCmsLayouts as $col=>$part){
						$CMShtml.="<div class='column ".$part['twelfths']."'>".$part['blocks']['blocktop'].$part['blocks']['blockbottom']."</div>";
					}
					$SU_Helper->createCmsPage($storeId,array(
						'title' => 'Student store',
						'identifier' => 'home',
						'content_heading' => '',
						'is_active' => 1,
						'stores' => array($storeId),//available for all store views
						'content' => str_replace('{CMShtml}',$CMShtml,$defaultCmsPage)
					));
					$cDat->saveConfig('wsu_themecontrol_design/spine/spine_color', 'crimson', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_design/spine/spine_tool_bar_color', 'lighter', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_design/spine/spine_bleed', '0', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_design/spine/max_width', '1188', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_design/spine/fluid_width', 'hybrid', 'websites', $siteId);
				}
			}
		}
	}


	$newRootCat = $SU_Helper->make_category("Tech store root");
	if($newRootCat>0){
		$SU_Helper->reparentCategory($newRootCat,24);
		$siteId = $SU_Helper->make_website(array('code'=>'techstore','name'=>'Tech store'));
		if( $siteId>0 ){
			$storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Tech Store'), 'tech.store.'.BASEURL.'', $siteId, $newRootCat );
			if( $storeGroupId>0 ){
				$storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'techstore','name'=>'base default veiw') );
				if( $storeId>0 ){
					$SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
					$storeCmsLayouts = array(
						'col1'=>array(
							'twelfths'=>'twelve-twelfths',
							'blocks'=>array(
								'blocktop'=>'<img src="{{storemedia url="/trasparent-placeholder-missing-image.png"}}" alt="" style="width:100%;min-height:150px;max-height:220px;" border="0" />',
								'blockbottom'=>'<div class="row">{{block type="catalog/product" products_limit="3" imgh="168" imgw="168" template="custom_block/topproduct.phtml"}}</div>'
							)
						)
					);
					$CMShtml="";
					foreach($storeCmsLayouts as $col=>$part){
						$CMShtml.="<div class='column ".$part['twelfths']."'>".$part['blocks']['blocktop'].$part['blocks']['blockbottom']."</div>";
					}
					$SU_Helper->createCmsPage($storeId,array(
						'title' => 'Tech store',
						'identifier' => 'home',
						'content_heading' => '',
						'is_active' => 1,
						'stores' => array($storeId),//available for all store views
						'content' => str_replace('{CMShtml}',$CMShtml,$defaultCmsPage)
					));
					$cDat->saveConfig('wsu_themecontrol_design/spine/spine_color', 'transparent', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_design/spine/spine_tool_bar_color', 'darkest', 'websites', $siteId);
				}
			}
		}
	}


	$newRootCat = $SU_Helper->make_category("General store root");
	if($newRootCat>0){
		$SU_Helper->reparentCategory($newRootCat,7);
		$siteId = $SU_Helper->make_website(array('code'=>'generalstore','name'=>'General store'));
		if( $siteId>0 ){
			$storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'General Store'), 'general.store.'.BASEURL.'', $siteId, $newRootCat );
			if( $storeGroupId>0 ){
				$storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'generalstore','name'=>'base default veiw') );
				if( $storeId>0 ){
					$SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );


					$storeCmsLayouts = array(
						'col1'=>array(
							'twelfths'=>'twelfths-12',
							'blocks'=>array(
								'blocktop'=>'<img src="{{storemedia url="/home_main_callout.jpg"}}" alt=""  border="0" />',
								'blockbottom'=>'<img src="{{storemedia url="/free_shipping_callout.jpg"}}" alt=""  border="0" />'
							)
						)
					);
					$CMShtml="";
					foreach($storeCmsLayouts as $col=>$part){
						$CMShtml.="<div class='column ".$part['twelfths']."'>".$part['blocks']['blocktop'].$part['blocks']['blockbottom']."</div>";
					}

					$SU_Helper->createCmsPage($storeId,array(
						'title' => 'General store',
						'identifier' => 'home',
						'content_heading' => '',
						'is_active' => 1,
						'stores' => array($storeId),//available for all store views
						'content' => str_replace('{CMShtml}',$CMShtml,$defaultCmsPage)
					));
					$cDat->saveConfig('wsu_themecontrol_layout/responsive/max_width', 'default', 'websites', $siteId);
					$cDat->saveConfig('wsu_themecontrol_layout/responsive/fluid_width', 'hybrid', 'websites', $siteId);
				}
			}
		}
	}



	if(Mage::getConfig()->getModuleConfig('Wsu_eventTickets')->is('active', 'true')){
		$websiteCodes = 'eventstore';//array('eventstore');
		$storeCodes = 'eventstore';//array('eventstore');
		echo $websiteCodes.'::websiteCodes'."\n";
		echo $storeCodes.'::storeCodes'."\n";

		$newRootCat = $SU_Helper->make_category("Event store root");
		if($newRootCat>0){
			$siteId = $SU_Helper->make_website(array('code'=>$websiteCodes,'name'=>'Event store'));
			if( $siteId>0 ){
				$storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Events Store'), 'events.store.'.BASEURL.'', $siteId, $newRootCat );
				if( $storeGroupId>0 ){
					$storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>$storeCodes,'name'=>'base default veiw') );
					if( $storeId>0 ){
						$SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
						$storeCmsLayouts = array(
							'col1'=>array(
								'twelfths'=>'seven-twelfths',
								'blocks'=>array(
									'blocktop'=>'<a href="{{store direct_url="#"}}"> <img src="{{storemedia url="/lefttop_ad_block.jpg"}}" alt="" border="0" /> </a>',
									'blockbottom'=>'<img src="{{storemedia url="/rightbottom_ad_block.jpg"}}" alt="" border="0" />'
								)
							),
							'col2'=>array(
								'twelfths'=>'five-twelfths',
								'blocks'=>array(
									'blocktop'=>'<img src="{{storemedia url="/trasparent-placeholder-missing-image.png"}}" alt=""  border="0" />',
									'blockbottom'=>'<img src="{{storemedia url="/trasparent-placeholder-missing-image.png"}}" alt=""  border="0" />'
								)
							)
						);
						$CMShtml="";
						foreach($storeCmsLayouts as $col=>$part){
							$CMShtml.="<div class='column ".$part['twelfths']."'>".$part['blocks']['blocktop'].$part['blocks']['blockbottom']."</div>";
						}
						$SU_Helper->createCmsPage($storeId,array(
							'title' => 'Event store',
							'identifier' => 'home',
							'content_heading' => '',
							'is_active' => 1,
							'stores' => array($storeId),//available for all store views
							'content' => str_replace('{CMShtml}',$CMShtml,$defaultCmsPage)
						));
						include_once('staging/scripts/sample-events.php');
						$cDat->saveConfig('wsu_themecontrol_design/spine/spine_color', 'darkest', 'websites', $siteId);
						$cDat->saveConfig('wsu_themecontrol_design/spine/spine_tool_bar_color', 'crimson', 'websites', $siteId);
					}
				}
			}
		}
	}
}
$output = ob_get_clean();
echo "name=post-install-settings result=True changed=True comment='$output'";
