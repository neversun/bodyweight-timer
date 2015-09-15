#include "applibrary.h"
#include <QDBusConnection>
#include <QDBusInterface>

appLibrary::appLibrary(QObject *parent) :
    QObject(parent)
{
}


/* Prevents screen going dark during video playback.
   true = no blanking
   false = blanks normally

   Credits to: https://github.com/skvark/SailKino
*/
void appLibrary::setBlankingMode(bool state)
{
    QDBusConnection system = QDBusConnection::connectToBus(QDBusConnection::SystemBus,
                                                           "system");

    QDBusInterface interface("com.nokia.mce",
                             "/com/nokia/mce/request",
                             "com.nokia.mce.request",
                             system);

    if (state) {
        interface.call(QLatin1String("req_display_blanking_pause"));
    } else {
        interface.call(QLatin1String("req_display_cancel_blanking_pause"));
    }

}
