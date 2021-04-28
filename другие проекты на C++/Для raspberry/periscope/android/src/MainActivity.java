package inc.garage;

import android.content.Context;
import android.os.Bundle;
import android.content.ComponentName;
import android.widget.Toast;
import android.net.NetworkInfo;
import android.net.ProxyInfo;
import android.net.ConnectivityManager;
import android.net.LinkAddress;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiConfiguration.KeyMgmt;
import android.net.wifi.ScanResult;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.text.TextUtils;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Field;
import java.lang.reflect.Constructor;
import java.lang.Class;
import java.lang.ClassNotFoundException;
import java.lang.IllegalAccessException;
import java.lang.NoSuchMethodException;
import java.lang.NoSuchFieldException;
import java.lang.InstantiationException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;
import java.util.ArrayList;


public class MainActivity extends org.qtproject.qt5.android.bindings.QtActivity {
    private WifiManager wifiManager;
    private WifiConfiguration wifiConfig;
    // private WifiReceiver wifiResiver;
    private boolean wifiEnabled;
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        Thread.setDefaultUncaughtExceptionHandler(new Restarter(this));
        if (getIntent().getBooleanExtra("crash", false)) {
            Toast.makeText(this, "Приложение перезапущено после аварийной остановки", Toast.LENGTH_SHORT).show();
        }


        // создаем новый объект для подключения к конкретной точке
        wifiConfig = new WifiConfiguration();
        // сканнер вайфая который нам будет помогать подключаться к нужной точке
        wifiManager = (WifiManager) getSystemService(Context.WIFI_SERVICE);

        // узнаем включен вайфай  или нет
        wifiEnabled = wifiManager.isWifiEnabled();

        // //если файвай включен то ничего не делаем иначе включаем его
        if(!wifiEnabled) {
            wifiManager.setWifiEnabled(true);
            try
            {
                Thread.sleep(10000);
            }
            catch(InterruptedException ex)
            {
                Thread.currentThread().interrupt();
            }
        }
        wifiConfig.SSID = "\"trololo-632\"";
        wifiConfig.preSharedKey  = "\"code2019\"";
        wifiConfig.hiddenSSID = true;
        wifiConfig.status = WifiConfiguration.Status.ENABLED;        
        wifiConfig.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
        wifiConfig.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
        wifiConfig.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
        wifiConfig.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
        wifiConfig.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
        wifiConfig.allowedProtocols.set(WifiConfiguration.Protocol.RSN);
        wifiConfig.status = WifiConfiguration.Status.ENABLED;

        // //получаем ID сети и пытаемся к ней подключиться, 
        // int netId = wifiManager.addNetwork(wifiConfig);
        // wifiManager.saveConfiguration();
        try {
            InetAddress ip = InetAddress.getByName("192.168.0.54");
            InetAddress gateway = InetAddress.getByName("192.168.0.1");
            InetAddress[] dns = new InetAddress[]{InetAddress.getByName("8.8.8.8")};
            String res = setStaticIpConfiguration(
                ip,
                24,
                gateway,
                dns
            );

            Toast.makeText(this, res, Toast.LENGTH_SHORT).show();
        }
        catch (UnknownHostException e) {Toast.makeText(this, "UnknownHostException", Toast.LENGTH_SHORT).show();}
        catch (ClassNotFoundException e) {Toast.makeText(this, "ClassNotFoundException", Toast.LENGTH_SHORT).show();}
        catch (IllegalAccessException e) {Toast.makeText(this, "IllegalAccessException", Toast.LENGTH_SHORT).show();}
        catch (InvocationTargetException e) {Toast.makeText(this, "InvocationTargetException", Toast.LENGTH_SHORT).show();}
        catch (NoSuchMethodException e) {Toast.makeText(this, "NoSuchMethodException", Toast.LENGTH_SHORT).show();}
        catch (NoSuchFieldException e) {Toast.makeText(this, "NoSuchFieldException", Toast.LENGTH_SHORT).show();}
        catch (InstantiationException e) {Toast.makeText(this, "InstantiationException", Toast.LENGTH_SHORT).show();}



        // //если вайфай выключен то включаем его
        // wifiManager.enableNetwork(netId, true);
        // //если же он включен но подключен к другой сети то перегружаем вайфай.
        // wifiManager.reconnect();
    }

    @SuppressWarnings("unchecked")
    public String setStaticIpConfiguration(
                        InetAddress ipAddress,
                        int prefixLength,
                        InetAddress gateway,
                        InetAddress[] dns) throws ClassNotFoundException,
                        IllegalAccessException, IllegalArgumentException, InvocationTargetException,
                        NoSuchMethodException, NoSuchFieldException, InstantiationException
    {
        // First set up IpAssignment to STATIC.
        Object ipAssignment = getEnumValue("android.net.IpConfiguration$IpAssignment", "STATIC");
        callMethod(wifiConfig, "setIpAssignment", new String[]{"android.net.IpConfiguration$IpAssignment"}, new Object[]{ipAssignment});

        // Then set properties in StaticIpConfiguration.
        Object staticIpConfig = newInstance("android.net.StaticIpConfiguration");
        Object linkAddress = newInstance("android.net.LinkAddress", new Class<?>[]{InetAddress.class, int.class}, new Object[]{ipAddress, prefixLength});

        setField(staticIpConfig, "ipAddress", linkAddress);
        setField(staticIpConfig, "gateway", gateway);
        // getField(staticIpConfig, "dnsServers", ArrayList.class).clear();
        // for (int i = 0; i < dns.length; i++)
        //     getField(staticIpConfig, "dnsServers", ArrayList.class).add(dns[i]);

        callMethod(wifiConfig, "setStaticIpConfiguration", new String[]{"android.net.StaticIpConfiguration"}, new Object[]{staticIpConfig});

        int netId = wifiManager.addNetwork(wifiConfig);
        wifiManager.saveConfiguration();
        // int netId = manager.updateNetwork(config);
        boolean result = netId != -1;
        if (result) {

            // boolean isDisconnected = manager.disconnect();
            boolean configSaved = wifiManager.saveConfiguration();
            //boolean isEnabled = manager.enableNetwork(netId, true);
            boolean isEnabled = wifiManager.enableNetwork(wifiConfig.networkId, true);
            wifiManager.setWifiEnabled(false);
            wifiManager.setWifiEnabled(true);
            boolean isReconnected = wifiManager.reconnect();
            return "okk";
        } else {
            return "fail";
        }
    }

    public static WifiConfiguration getCurrentWiFiConfiguration(Context context) {
        WifiConfiguration wifiConf = null;
        ConnectivityManager connManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo networkInfo = connManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
        if (networkInfo.isConnected()) {
            final WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
            final WifiInfo connectionInfo = wifiManager.getConnectionInfo();
            if (connectionInfo != null && !TextUtils.isEmpty(connectionInfo.getSSID())) {
                List<WifiConfiguration> configuredNetworks = wifiManager.getConfiguredNetworks();
                if (configuredNetworks != null) {
                    for (WifiConfiguration conf : configuredNetworks) {
                        if (conf.networkId == connectionInfo.getNetworkId()) {
                            wifiConf = conf;
                            break;
                        }
                    }
                }
            }
        }
        return wifiConf;
    }

    private static Object newInstance(String className) throws ClassNotFoundException, InstantiationException, IllegalAccessException, NoSuchMethodException, IllegalArgumentException, InvocationTargetException
    {
        return newInstance(className, new Class<?>[0], new Object[0]);
    }

    private static Object newInstance(String className, Class<?>[] parameterClasses, Object[] parameterValues) throws NoSuchMethodException, InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, 
    ClassNotFoundException {
        Class<?> clz = Class.forName(className);
        Constructor<?> constructor = clz.getConstructor(parameterClasses);
        return constructor.newInstance(parameterValues);
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    private static Object getEnumValue(String enumClassName, String enumValue) throws ClassNotFoundException {
        Class<Enum> enumClz = (Class<Enum>) Class.forName(enumClassName);
        return Enum.valueOf(enumClz, enumValue);
    }

    private static void setField(Object object, String fieldName, Object value) throws IllegalAccessException, IllegalArgumentException, NoSuchFieldException {
        Field field = object.getClass().getDeclaredField(fieldName);
        field.set(object, value);
    }

    private static <T> T getField(Object object, String fieldName, Class<T> type) throws IllegalAccessException, IllegalArgumentException, NoSuchFieldException {
        Field field = object.getClass().getDeclaredField(fieldName);
        return type.cast(field.get(object));
    }

    private static void callMethod(Object object, String methodName, String[] parameterTypes, Object[] parameterValues) throws ClassNotFoundException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, NoSuchMethodException {
        Class<?>[] parameterClasses = new Class<?>[parameterTypes.length];
        for (int i = 0; i < parameterTypes.length; i++)
            parameterClasses[i] = Class.forName(parameterTypes[i]);

        Method method = object.getClass().getDeclaredMethod(methodName, parameterClasses);
        method.invoke(object, parameterValues);
    }

    // public void scheduleSendLocation() {
    //     registerReceiver(wifiResiver, new IntentFilter(WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
    //     wifiManager.startScan();
    // }

    // /*
    //  * Рессивер который каждый раз запускает сканнер сети 
    //  * */
    // public class WifiReceiver extends BroadcastReceiver {
            
    //     @Override
    //     public void onReceive(Context c, Intent intent) {  
    //         //сканируем вайфай точки и узнаем какие доступны
    //         //List<ScanResult> results = wifiManager.getScanResults();
    //         //проходимся по всем возможным точкам
    //         // for (final ScanResult ap : results) {
    //                //ищем нужную нам точку с помощью ифа, будет находить то которую вы ввели
    //            // if(ap.SSID.toString().trim().equals("kkt")) {
    //                 // дальше получаем ее MAC и передаем для коннекрта, MAC получаем из результата
    //                 //здесь мы уже начинаем коннектиться
    //         // Toast.makeText(this, "Поднимаем перископ", Toast.LENGTH_SHORT).show();
    //                 wifiConfig.BSSID = "D8:68:C3:4D:2B:3E";//ap.BSSID; //MAC адрес
    //                 wifiConfig.SSID = "kkt";//ap.BSSID; //MAC адрес
    //                 wifiConfig.priority = 1;
    //                 wifiConfig.allowedKeyManagement.set(KeyMgmt.NONE);
    //                 wifiConfig.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
    //                 wifiConfig.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
    //                 // wifiConfig.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
    //                 wifiConfig.status = WifiConfiguration.Status.ENABLED;

    //                 //получаем ID сети и пытаемся к ней подключиться, 
    //                 int netId = wifiManager.addNetwork(wifiConfig);
    //                 wifiManager.saveConfiguration();
    //                 //если вайфай выключен то включаем его
    //                 wifiManager.enableNetwork(netId, true);
    //                 //если же он включен но подключен к другой сети то перегружаем вайфай.
    //                 wifiManager.reconnect();                
    //                 // break;
    //         //     }
    //         // }
    //     }
    // }
}