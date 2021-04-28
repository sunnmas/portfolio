#ifndef TELEMETRY_H
#define TELEMETRY_H

#define TELEMETRY_SIZE sizeof(Telemetry)
struct TelemetryStruct {
    unsigned char charge;
    float deep;
};

class Telemetry
{
public:
    explicit Telemetry();
    TelemetryStruct *read();
private:
	TelemetryStruct telemetry;
};
#endif //TELEMETRY_H