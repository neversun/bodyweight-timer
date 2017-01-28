#include <QtQuick>

#include <sailfishapp.h>
#include "applibrary.h"

int main(int argc, char *argv[])
{
    QGuiApplication *app = SailfishApp::application(argc, argv);
    QQuickView *view = SailfishApp::createView();

    appLibrary* applib = new appLibrary();
    view->rootContext()->setContextProperty("appLibrary", applib);

    qDebug() << "Import path" << SailfishApp::pathTo("lib/").toLocalFile();
    view->engine()->addImportPath(SailfishApp::pathTo("lib/").toLocalFile());

    view->setSource(SailfishApp::pathTo("qml/harbour-bodyweighttimer.qml"));

    view->showFullScreen();
    app->exec();
}

