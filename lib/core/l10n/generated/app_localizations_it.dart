// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Patrimonio';

  @override
  String get appTagline =>
      'Monitora il tuo patrimonio aggiornandolo una volta al mese.';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionDone => 'Fine';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionArchive => 'Archivia';

  @override
  String get actionRestore => 'Ripristina';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionDiscard => 'Esci senza salvare';

  @override
  String get actionKeepEditing => 'Continua a modificare';

  @override
  String get actionMore => 'Altre azioni';

  @override
  String get navHome => 'Home';

  @override
  String get navAssets => 'Patrimonio';

  @override
  String get navInvestments => 'Investimenti';

  @override
  String get navHistory => 'Storico';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get updateWealthCta => 'Aggiorna patrimonio';

  @override
  String get updateWealthShort => 'Aggiorna';

  @override
  String get openSettings => 'Apri le impostazioni';

  @override
  String get greetingMorning => 'Buongiorno';

  @override
  String get greetingAfternoon => 'Buon pomeriggio';

  @override
  String get greetingEvening => 'Buonasera';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get netWorth => 'Patrimonio netto';

  @override
  String get grossWorth => 'Patrimonio lordo';

  @override
  String get totalAssets => 'Attività';

  @override
  String get totalLiabilities => 'Passività';

  @override
  String get thisMonth => 'questo mese';

  @override
  String get firstUpdate => 'Primo aggiornamento';

  @override
  String get unchanged => 'invariato';

  @override
  String get distributionTitle => 'Dove sono i tuoi soldi';

  @override
  String get distributionEmpty =>
      'Aggiungi delle attività per vedere come è distribuito il tuo patrimonio.';

  @override
  String get otherCategory => 'Altro';

  @override
  String get chartSinglePoint =>
      'Il grafico prenderà forma dal prossimo aggiornamento.';

  @override
  String get reminderMessage => 'È ora di aggiornare il tuo patrimonio.';

  @override
  String get reminderAction => 'Aggiorna ora';

  @override
  String get emptyDashboardTitle => 'Non hai ancora nessun aggiornamento.';

  @override
  String get emptyDashboardMessage =>
      'Inserisci i valori di oggi: da qui in poi vedrai crescere il grafico.';

  @override
  String get emptyDashboardAction => 'Inserisci il primo patrimonio';

  @override
  String get recentUpdates => 'Ultimi aggiornamenti';

  @override
  String get seeAll => 'Vedi tutti';

  @override
  String get rangeThreeMonths => '3M';

  @override
  String get rangeSixMonths => '6M';

  @override
  String get rangeOneYear => '1A';

  @override
  String get rangeThreeYears => '3A';

  @override
  String get rangeAll => 'Tutto';

  @override
  String get rangeThreeMonthsLong => 'Ultimi 3 mesi';

  @override
  String get rangeSixMonthsLong => 'Ultimi 6 mesi';

  @override
  String get rangeOneYearLong => 'Ultimo anno';

  @override
  String get rangeThreeYearsLong => 'Ultimi 3 anni';

  @override
  String get rangeAllLong => 'Tutto lo storico';

  @override
  String chartSemantics(
    String title,
    String startValue,
    String startMonth,
    String endValue,
    String endMonth,
  ) {
    return '$title: da $startValue a $startMonth a $endValue a $endMonth';
  }

  @override
  String shareOfTotal(String percent) {
    return '$percent del totale';
  }

  @override
  String trendUp(String amount) {
    return 'in aumento di $amount';
  }

  @override
  String trendDown(String amount) {
    return 'in calo di $amount';
  }

  @override
  String get assetsTitle => 'Patrimonio';

  @override
  String assetsSubtitle(String month) {
    return 'Valori dell\'aggiornamento di $month';
  }

  @override
  String get assetsSubtitleNone =>
      'Nessun aggiornamento salvato: i valori compariranno dopo il primo.';

  @override
  String get newItem => 'Nuova voce';

  @override
  String get newCategory => 'Nuova categoria';

  @override
  String get editItem => 'Modifica voce';

  @override
  String get editCategory => 'Modifica categoria';

  @override
  String get nameLabel => 'Nome';

  @override
  String get itemNameHint => 'Es. Conto corrente';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get categoryNameHint => 'Es. Liquidità';

  @override
  String get categoryKindLabel => 'Tipo';

  @override
  String get kindAsset => 'Attività';

  @override
  String get kindLiability => 'Passività';

  @override
  String get isInvestmentLabel => 'Conta come investimento';

  @override
  String get isInvestmentHelp =>
      'Le voci di questa categoria compaiono nella sezione Investimenti.';

  @override
  String get kindLockedHelp => 'Il tipo non si può cambiare dopo la creazione.';

  @override
  String get archiveHint =>
      'Archiviare non cancella lo storico: la voce non comparirà più nei prossimi aggiornamenti.';

  @override
  String get archivedTitle => 'Archiviati';

  @override
  String get archivedBadge => 'Archiviata';

  @override
  String get deleteItemTitle => 'Eliminare la voce?';

  @override
  String get deleteItemMessage =>
      'La voce sparirà dall\'elenco. I valori già salvati negli aggiornamenti passati restano nello storico.';

  @override
  String get deleteCategoryTitle => 'Eliminare la categoria?';

  @override
  String get deleteCategoryMessage =>
      'Si può eliminare solo una categoria senza voci. Gli aggiornamenti passati non cambiano.';

  @override
  String get emptyCatalogTitle => 'Non hai ancora nessuna voce.';

  @override
  String get emptyCatalogMessage =>
      'Aggiungi i conti, gli investimenti, i beni e i debiti che vuoi seguire.';

  @override
  String get categoryEmptyItems => 'Nessuna voce in questa categoria.';

  @override
  String get reorderHint =>
      'Trascina le voci per riordinarle. Usa le frecce per spostare le categorie.';

  @override
  String get moveUp => 'Sposta su';

  @override
  String get moveDown => 'Sposta giù';

  @override
  String get dragToReorder => 'Trascina per riordinare';

  @override
  String get investmentBadge => 'Investimento';

  @override
  String get validationRequired => 'Campo obbligatorio';

  @override
  String validationTooLong(int max) {
    return 'Massimo $max caratteri';
  }

  @override
  String get itemCategoryMissing => 'Crea prima una categoria.';

  @override
  String get updateTitle => 'Aggiorna patrimonio';

  @override
  String get editUpdateTitle => 'Modifica aggiornamento';

  @override
  String get prefilledHint =>
      'Valori del mese scorso già inseriti: modifica solo quello che è cambiato.';

  @override
  String editingExistingHint(String month) {
    return 'Stai modificando l\'aggiornamento di $month.';
  }

  @override
  String get firstUpdateHint =>
      'Inserisci il valore attuale di ogni voce. Per i debiti, quanto resta da pagare.';

  @override
  String get addItem => 'Aggiungi voce';

  @override
  String get saveUpdate => 'Salva aggiornamento';

  @override
  String get savedMessage => 'Aggiornamento salvato';

  @override
  String get unsavedChangesTitle => 'Uscire senza salvare?';

  @override
  String get unsavedChangesMessage =>
      'Le modifiche a questo aggiornamento andranno perse.';

  @override
  String get previousMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String get summaryTitle => 'Riepilogo';

  @override
  String get keyboardHints =>
      'Tab: campo successivo · Ctrl/⌘+S: salva · Esc: chiudi';

  @override
  String get noItemsToUpdate =>
      'Non hai voci attive. Aggiungine una per iniziare.';

  @override
  String amountFieldLabel(String name) {
    return 'Importo di $name';
  }

  @override
  String get amountInvalid => 'Importo non valido';

  @override
  String get amountNegative =>
      'Scrivi un numero positivo: le passività si inseriscono senza segno.';

  @override
  String get amountTooManyDecimals => 'Usa al massimo due decimali.';

  @override
  String get amountTooLarge => 'Importo troppo grande';

  @override
  String get fixErrorsBeforeSaving =>
      'Correggi i campi segnalati prima di salvare.';

  @override
  String get monthChangeTitle => 'Cambiare mese?';

  @override
  String get monthChangeMessage =>
      'I valori che hai inserito per questo mese non sono ancora salvati e andranno persi.';

  @override
  String get changeMonth => 'Cambia mese';

  @override
  String get historyTitle => 'Storico';

  @override
  String get historyEmptyTitle => 'Nessun aggiornamento salvato.';

  @override
  String get historyEmptyMessage => 'Ogni mese che aggiorni comparirà qui.';

  @override
  String get selectUpdateHint =>
      'Seleziona un aggiornamento per vedere il dettaglio.';

  @override
  String get editValues => 'Modifica valori';

  @override
  String get deleteUpdate => 'Elimina aggiornamento';

  @override
  String deleteUpdateTitle(String month) {
    return 'Eliminare l\'aggiornamento di $month?';
  }

  @override
  String get deleteUpdateMessage =>
      'I valori di questo mese verranno cancellati. Gli altri mesi non cambiano.';

  @override
  String get updateDeleted => 'Aggiornamento eliminato';

  @override
  String get updateNotFound => 'Questo aggiornamento non esiste più.';

  @override
  String get investmentsTitle => 'Investimenti';

  @override
  String get investmentsValue => 'Valore investimenti';

  @override
  String get monthlyChange => 'Questo mese';

  @override
  String get lastMonthChange => 'Ultimo mese';

  @override
  String get yearlyChange => 'Ultimi 12 mesi';

  @override
  String sinceMonth(String month) {
    return 'Da $month';
  }

  @override
  String get breakdownTitle => 'Ripartizione';

  @override
  String get investmentsChartTitle => 'Valore degli investimenti';

  @override
  String get investmentsEmptyTitle => 'Non hai ancora voci di investimento.';

  @override
  String get investmentsEmptyMessage =>
      'Nella sezione Patrimonio segna una categoria come investimento per vederla qui.';

  @override
  String get goToAssets => 'Vai a Patrimonio';

  @override
  String get noInvestmentValues =>
      'Nessun valore di investimento nell\'ultimo aggiornamento.';

  @override
  String get loginTitle => 'Accedi';

  @override
  String get loginSubtitle => 'Bentornato. Inserisci le tue credenziali.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get loginAction => 'Accedi';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get signUpLink => 'Registrati';

  @override
  String get tryDemo => 'Prova la demo';

  @override
  String get signUpTitle => 'Crea il tuo account';

  @override
  String get signUpSubtitle => 'Bastano un\'email e una password.';

  @override
  String get signUpAction => 'Crea account';

  @override
  String get haveAccount => 'Hai già un account?';

  @override
  String get passwordHelper => 'Almeno 8 caratteri';

  @override
  String get confirmEmailTitle => 'Controlla la tua email';

  @override
  String confirmEmailMessage(String email) {
    return 'Ti abbiamo inviato un link di conferma a $email. Aprilo per attivare l\'account, poi accedi.';
  }

  @override
  String get backToLogin => 'Torna all\'accesso';

  @override
  String get forgotTitle => 'Recupera la password';

  @override
  String get forgotMessage =>
      'Inserisci l\'email del tuo account: ti invieremo un link per scegliere una nuova password.';

  @override
  String get forgotAction => 'Invia link';

  @override
  String forgotSentMessage(String email) {
    return 'Se esiste un account con $email, riceverai a breve un\'email con il link.';
  }

  @override
  String get resetTitle => 'Nuova password';

  @override
  String get resetMessage => 'Scegli una nuova password per il tuo account.';

  @override
  String get newPasswordLabel => 'Nuova password';

  @override
  String get confirmPasswordLabel => 'Ripeti la password';

  @override
  String get resetAction => 'Salva password';

  @override
  String get passwordUpdated => 'Password aggiornata';

  @override
  String get invalidEmail => 'Inserisci un\'email valida';

  @override
  String get passwordTooShort => 'La password deve avere almeno 8 caratteri';

  @override
  String get passwordsDoNotMatch => 'Le password non coincidono';

  @override
  String get supabaseNotConfigured =>
      'Il collegamento al server non è configurato. Puoi provare l\'app in modalità demo.';

  @override
  String get showPassword => 'Mostra password';

  @override
  String get hidePassword => 'Nascondi password';

  @override
  String get welcomeTitle => 'Benvenuto';

  @override
  String get start => 'Inizia';

  @override
  String stepOf(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get chooseItemsTitle => 'Cosa possiedi?';

  @override
  String get chooseItemsMessage =>
      'Scegli le voci da seguire. Potrai cambiarle quando vuoi.';

  @override
  String get chooseAtLeastOne => 'Scegli almeno una voce per continuare.';

  @override
  String get firstValuesTitle => 'Quanto vale oggi?';

  @override
  String get firstValuesMessage =>
      'Scrivi il valore attuale di ogni voce. Per i debiti, quanto resta da pagare.';

  @override
  String get finishOnboarding => 'Salva e vai alla home';

  @override
  String get catLiquidity => 'Liquidità';

  @override
  String get catInvestments => 'Investimenti';

  @override
  String get catRealEstate => 'Immobili';

  @override
  String get catOtherAssets => 'Altri beni';

  @override
  String get catDebts => 'Debiti';

  @override
  String get itemCurrentAccount => 'Conto corrente';

  @override
  String get itemDepositAccount => 'Conto deposito';

  @override
  String get itemCash => 'Contanti';

  @override
  String get itemEtf => 'ETF';

  @override
  String get itemStocks => 'Azioni';

  @override
  String get itemBonds => 'Obbligazioni';

  @override
  String get itemCrypto => 'Crypto';

  @override
  String get itemPensionFund => 'Fondo pensione';

  @override
  String get itemHome => 'Casa';

  @override
  String get itemCar => 'Auto';

  @override
  String get itemMortgage => 'Mutuo';

  @override
  String get itemLoan => 'Prestito';

  @override
  String get itemCreditCard => 'Carta di credito';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get profileSection => 'Profilo';

  @override
  String get displayNameLabel => 'Nome';

  @override
  String get displayNameHint => 'Il nome da mostrare nella home';

  @override
  String get appearanceSection => 'Aspetto';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get securitySection => 'Sicurezza';

  @override
  String get changePassword => 'Cambia password';

  @override
  String get accountSection => 'Account';

  @override
  String get signOut => 'Esci';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountMessage =>
      'Tutti i tuoi dati verranno cancellati in modo definitivo: voci, categorie e aggiornamenti. L\'operazione non si può annullare.';

  @override
  String get deleteAccountConfirm => 'Elimina definitivamente';

  @override
  String get profileSaved => 'Profilo aggiornato';

  @override
  String get exitDemo => 'Esci dalla demo';

  @override
  String get demoSettingsNote =>
      'Nella demo le impostazioni dell\'account non sono disponibili.';

  @override
  String signedInAs(String email) {
    return 'Accesso effettuato come $email';
  }

  @override
  String get demoBanner => 'Modalità demo · dati di esempio, non salvati';

  @override
  String get demoExit => 'Esci';

  @override
  String get errorNetwork =>
      'Non riesco a collegarmi. Controlla la connessione e riprova.';

  @override
  String get errorSessionExpired => 'La sessione è scaduta. Accedi di nuovo.';

  @override
  String get errorInvalidCredentials => 'Email o password non corrette.';

  @override
  String get errorEmailNotConfirmed =>
      'Devi prima confermare l\'email: controlla la tua casella di posta.';

  @override
  String get errorEmailAlreadyUsed => 'Esiste già un account con questa email.';

  @override
  String get errorWeakPassword =>
      'La password è troppo debole. Usane una più lunga o più varia.';

  @override
  String get errorSamePassword =>
      'La nuova password deve essere diversa da quella attuale.';

  @override
  String get errorRateLimited =>
      'Troppi tentativi. Riprova tra qualche minuto.';

  @override
  String get errorMonthAlreadyExists => 'Questo mese ha già un aggiornamento.';

  @override
  String get errorCategoryNotEmpty =>
      'La categoria contiene ancora delle voci. Spostale o eliminale prima.';

  @override
  String get errorNotFound => 'L\'elemento non esiste più.';

  @override
  String get errorPermissionDenied =>
      'Non hai i permessi per questa operazione.';

  @override
  String get errorNotConfigured =>
      'Il collegamento al server non è configurato.';

  @override
  String get errorInvalidData => 'Alcuni dati non sono validi.';

  @override
  String get errorServer =>
      'Il server non risponde come dovrebbe. Riprova tra poco.';

  @override
  String get errorUnknown => 'Qualcosa è andato storto. Riprova.';

  @override
  String get saveFailed =>
      'Salvataggio non riuscito. I tuoi dati sono ancora qui: riprova.';

  @override
  String get pageNotFound => 'Pagina non trovata.';

  @override
  String get goHome => 'Torna alla home';

  @override
  String get loading => 'Caricamento…';

  @override
  String get demoModeLabel => 'Modalità demo';
}
