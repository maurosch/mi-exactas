import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
const serviceAccount = require("../firebase-secret.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: "satapp-27658.appspot.com",
});

export const PUBSUB_FUNCTION = (interval: string, f: (context: functions.EventContext) => any) =>
    functions.region("southamerica-east1").pubsub.schedule(interval).timeZone("America/Argentina/Buenos_Aires").onRun(f);


export const pubSubNotificateFinales = PUBSUB_FUNCTION(
    "0 12 * * *",
    async (context) => {
        await notificateFinales()
    }
);

const notificateFinales = async () => {
    var startOfToday = new Date(); 
    startOfToday.setHours(0,0,0,0);
    var endOfToday = new Date(); 
    endOfToday.setHours(23,59,59,999);

    const data = (await admin.firestore().collection('events').where('type','==',TypeEvent.finales)
    .get()).docs.map((v) => v.data() as EventFb)

    for(var x of data){
        console.log(x)
        const diffInDays = Math.ceil(Math.abs((x.date_start.toDate() as any) - (new Date() as any))/ (1000 * 60 * 60 * 24))
        console.log(diffInDays)
        if(diffInDays == 12){
            await admin.messaging().sendToTopic('Finales',{
                notification: {
                    title: 'Fecha de finales',
                    body: 'En dos semanas hay mesas de finales'
                }
            })
        } 
    }
}

export const onCallNotificateFinales = functions.region('southamerica-east1').https.onCall( async (data, context) => {
    await notificateFinales();
    return true;
})

interface EventFb {
    date_start: FirebaseFirestore.Timestamp,
    date_end: FirebaseFirestore.Timestamp,
    name: string
    type: TypeEvent
}

enum TypeEvent { inscripcion_finales, finales }


