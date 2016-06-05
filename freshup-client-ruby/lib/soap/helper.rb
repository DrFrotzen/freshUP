module FreshupClient
  module Soap

    ERRORS = [
      "ALREADYHELD",        # die Karte gehoert dieser Gruppe schon (bsp: Karten vergeben)
      "ALREADYLOCKED",      # die Gruppe kann nicht gesperrt werden, da sie bereits gesperrt ist
      "ALREADYSOLVED",      # diese Karte wurde bereits gelöst
      "EMPTY",              # das Ergebnis ist leer (das Interface konnte keine leeren Listen empfangen - daher dieser Workaround)
      "ERROR",              # ein interner Fehler ist aufgetreten (bsp:Datenbank)
      "ERRORFORBIDDEN",     # Der Benutzer hat kein Recht dies auszufuehren (bsp: fremde Profile betrachten)
      "GROUPDISABLED",      # Die Gruppe des Spielers wurde gesperrt (bsp:gegen Regeln verstoßen)
      "GROUPEMPTY",         # diese Gruppe ist leer (bsp:Karten koennen keiner leeren Gruppe gegeben werden, da sonst der Studiengang der Gruppe nicht erkennbar ist)
      "GROUPFULL",          # die Gruppe ist bereits voll (bsp: Spieler zu einer Gruppe mit der maximalen Spielerzahl hinzufuegen)
      "GROUPNOTEXISTENT",   # die gewaehlte Gruppe existiert nicht (bsp: Gruppen loeschen die nicht existiert)
      "MESSAGENOTEXISTENT", # die Nachricht existiert nicht oder ist nicht fuer diesen Spieler zugaenglich (Spieler ist weder Absender noch Empfaenger)
      "NOCONNECTION",       # der AufgabenServer ist nicht bereit/verbunden (bsp:Spielstart)
      "NOTADMIN",           # Das ist kein Administrator/falsches Passwort
      "NOTLOCKED",          # die Gruppe kann nicht entsperrt werden, da sie nicht gesperrt ist
      "SESSIONERROR",       # Die Session existiert nicht (mehr?)
      "TASKNOTAVAILABLE",   # diese Karte existiert, ist aber derzeit nicht auswählbar (bsp:Nutzer A und Nutzer B wollen gleichzeitig die selbe Karte tauschen - einer bekommt den Tauschzaehler zurueck, der 
      "TASKNOTEXISTENT",    # diese Aufgabe gibt es nicht (bsp:angucken einer Karte mit falscher ID)
      "UNKNOWNINTERACTIONTYPE",
      "USERNOTEXISTENT",    # der angegebene Benutzer existiert (laut Game#Engine#DB) nicht
      "USERNOTINGROUP",     # der Benutzer versucht eine Funktion aufzurufen, die nur innerhalb einer Gruppe erlaubt ist. Der Benutzer ist jedoch keiner Gruppe zugeordnet. Beim Spieler aus#iner#Gruppe#nehmen 
      "WITHERRORS",         # mindestens eine Nachricht enthält einen Fehler und ist mit ERROR gekenzeichnet
      "WRONGADMIN",         # Der Administrator hat die falsche Rechteklasse (bsp:Content#Admin versucht an Spielern zu arbeiten)
      "WRONGFORMAT",        # Parameter falsch übergeben
      "WRONGGAMECYCLE",     # diese Aktion lässt sich nur in einer anderen Spielphase ausführen (bsp:Karten beantworten, obwohl wir schon in der Marktplatzphase sind)
    ]
    
  end
end