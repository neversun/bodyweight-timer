#ifndef APPLIBRARY_H
#define APPLIBRARY_H

#include <QObject>

class appLibrary : public QObject
{
    Q_OBJECT
public:
    explicit appLibrary(QObject *parent = 0);
    Q_INVOKABLE void setBlankingMode(bool state);

signals:

public slots:

};

#endif // APPLIBRARY_H
