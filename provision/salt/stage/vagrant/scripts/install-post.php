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
$argv = $_SERVER['argv'];

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
$settingsarray = Mage::helper('storeutilities/utilities')->csv_to_array('staging/scripts/settings.config');
foreach($settingsarray as $item){
    $val =  $item['value']=="NULL"?NULL:$item['value'];
    $cDat->saveConfig($item['path'], $val, 'default', 0);
}
$cDat->saveConfig('admin/url/custom', 'http://store.admin.mage.dev/', 'default', 0);
 
echo "Applying the default multi-store setup\n";

$defaultCmsPage = '<div class="col-left side-col">
	<p class="home-callout"><a href="{{store direct_url="#"}}"> <img src="{{storemedia url="/ph_callout_left_top.jpg"}}" alt="" border="0" /> </a></p>
	<p class="home-callout"><img src="{{storemedia url="/ph_callout_left_rebel.jpg"}}" alt="" border="0" /></p>
	{{block type="tag/popular" template="tag/popular.phtml"}}</div>
	<div class="home-spot">
	<p class="home-callout"><img src="{{storemedia url="/home_main_callout.jpg"}}" alt="" width="535" border="0" /></p>
	<p class="home-callout"><img src="{{storemedia url="/free_shipping_callout.jpg"}}" alt="" width="535" border="0" /></p>
	</div>
	<h1>Sites in the center</h1>
	<p>{{block type="catalog/product" stores_per="5" products_per="2" panles_per="3" template="custom_block/site_list.phtml"}}</p>';

$SU_Helper = Mage::helper('storeutilities/utilities');

$newRootCat = $SU_Helper->make_category("General store root");
if($newRootCat>0){
    $SU_Helper->reparentCategory($newRootCat,18);
    $siteId = $SU_Helper->make_website(array('code'=>'generalstore','name'=>'General store'));
    if( $siteId>0 ){
        $storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'General Store'), 'general.store.mage.dev', $siteId, $newRootCat );
        if( $storeGroupId>0 ){
            $storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'generalstore','name'=>'base default veiw') );
            if( $storeId>0 ){
                $SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
                $SU_Helper->createCmsPage($storeId,array(
                    'title' => 'General store',
                    'identifier' => 'home',
                    'content_heading' => '',
                    'is_active' => 1,
                    'stores' => array($storeId),//available for all store views
                    'content' => $defaultCmsPage
                ));
                $cDat->saveConfig('wsu_themecontrol_layout/responsive/max_width', 'default', 'websites', $siteId);
                $cDat->saveConfig('wsu_themecontrol_layout/responsive/fluid_width', 'hybrid', 'websites', $siteId);
            }echo "make_store ended in {$storeId}\n";
        }echo "make_storeGroup ended in {$storeGroupId}\n";
    }echo "make_website ended in {$siteId}\n";
}echo "make_category ended in {$newRootCat}\n";
echo "-----------------------------------------\n";

$newRootCat = $SU_Helper->make_category("Student store root");
if($newRootCat>0){
    $SU_Helper->reparentCategory($newRootCat,10);
    $siteId = $SU_Helper->make_website(array('code'=>'studentstore','name'=>'Student store'));
    if( $siteId>0 ){
        $storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Student Store'), 'student.store.mage.dev', $siteId, $newRootCat );
        if( $storeGroupId>0 ){
            $storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'studentstore','name'=>'base default veiw') );
            if( $storeId>0 ){
                $SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
                $SU_Helper->createCmsPage($storeId,array(
                    'title' => 'Student store',
                    'identifier' => 'home',
                    'content_heading' => '',
                    'is_active' => 1,
                    'stores' => array($storeId),//available for all store views
                    'content' => $defaultCmsPage
                ));
            }echo "make_store ended in {$storeId}\n";
        }echo "make_storeGroup ended in {$storeGroupId}\n";
    }echo "make_website ended in {$siteId}\n";
}echo "make_category ended in {$newRootCat}\n";
echo "-----------------------------------------\n";

$newRootCat = $SU_Helper->make_category("Tech store root");
if($newRootCat>0){
    $SU_Helper->reparentCategory($newRootCat,13);
    $siteId = $SU_Helper->make_website(array('code'=>'techstore','name'=>'Tech store'));
    if( $siteId>0 ){
        $storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Tech Store'), 'tech.store.mage.dev', $siteId, $newRootCat );
        if( $storeGroupId>0 ){
            $storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>'techstore','name'=>'base default veiw') );
            if( $storeId>0 ){
                $SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
                $SU_Helper->createCmsPage($storeId,array(
                    'title' => 'Tech store',
                    'identifier' => 'home',
                    'content_heading' => '',
                    'is_active' => 1,
                    'stores' => array($storeId),//available for all store views
                    'content' => $defaultCmsPage
                ));
                $cDat->saveConfig('wsu_themecontrol_design/spine/spine_color', 'transparent', 'websites', $siteId);
                $cDat->saveConfig('wsu_themecontrol_design/spine/spine_tool_bar_color', 'darkest', 'websites', $siteId);
            }echo "make_store ended in {$storeId}\n";
        }echo "make_storeGroup ended in {$storeGroupId}\n";
    }echo "make_website ended in {$siteId}\n";
}echo "make_category ended in {$newRootCat}\n";
echo "-----------------------------------------\n";


$websiteCodes = 'eventstore';//array('eventstore');
$storeCodes = 'eventstore';//array('eventstore');
echo $websiteCodes.'::websiteCodes'."\n";
echo $storeCodes.'::storeCodes'."\n";

$newRootCat = $SU_Helper->make_category("Event store root");
if($newRootCat>0){
    $siteId = $SU_Helper->make_website(array('code'=>$websiteCodes,'name'=>'Event store'));
    if( $siteId>0 ){
        $storeGroupId = $SU_Helper->make_storeGroup( array('name'=>'Events Store'), 'events.store.mage.dev', $siteId, $newRootCat );
        if( $storeGroupId>0 ){
            $storeId = $SU_Helper->make_store( $siteId, $storeGroupId, array('code'=>$storeCodes,'name'=>'base default veiw') );
            if( $storeId>0 ){
                $SU_Helper->moveStoreProducts( $siteId, $storeId, $newRootCat );
                $SU_Helper->createCmsPage($storeId,array(
                    'title' => 'Event store',
                    'identifier' => 'home',
                    'content_heading' => '',
                    'is_active' => 1,
                    'stores' => array($storeId),//available for all store views
                    'content' => $defaultCmsPage
                ));
                include_once('staging/scripts/sample-events.php');
                $cDat->saveConfig('wsu_themecontrol_design/spine/spine_color', 'darkest', 'websites', $siteId);
                $cDat->saveConfig('wsu_themecontrol_design/spine/spine_tool_bar_color', 'crimson', 'websites', $siteId);
            }echo "make_store ended in {$storeId}\n";
        }echo "make_storeGroup ended in {$storeGroupId}\n";
    }echo "make_website ended in {$siteId}\n";
}echo "make_category ended in {$newRootCat}\n";
echo "-----------------------------------------\n";


// let us refresh the cache
try {
    $allTypes = Mage::app()->useCache();
    foreach($allTypes as $type => $blah) {
      Mage::app()->getCacheInstance()->cleanType($type);
    }
} catch (Exception $e) {
    // do something
    error_log($e->getMessage());
}


$types = Mage::app()->getCacheInstance()->getTypes();
try {
    echo "Cleaning data cache... \n";
    flush();
    foreach ($types as $type => $data) {
        echo "Removing $type ... ";
        echo Mage::app()->getCacheInstance()->clean($data["tags"]) ? "[OK]" : "[ERROR]";
        echo "\n";
    }
} catch (exception $e) {
    die("[ERROR:" . $e->getMessage() . "]");
}

echo "\n";

try {
    echo "Cleaning stored cache... ";
    flush();
    echo Mage::app()->getCacheInstance()->clean() ? "[OK]" : "[ERROR]";
    echo "\n\n";
} catch (exception $e) {
    die("[ERROR:" . $e->getMessage() . "]");
}

$output = ob_get_clean();
echo "name=post-install-settings result=True changed=True comment='$output'";
