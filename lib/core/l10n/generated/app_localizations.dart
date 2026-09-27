import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('it')];

  /// No description provided for @appName.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In it, this message translates to:
  /// **'Monitora il tuo patrimonio aggiornandolo una volta al mese.'**
  String get appTagline;

  /// No description provided for @actionSave.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In it, this message translates to:
  /// **'Riprova'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get actionClose;

  /// No description provided for @actionDelete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get actionEdit;

  /// No description provided for @actionDone.
  ///
  /// In it, this message translates to:
  /// **'Fine'**
  String get actionDone;

  /// No description provided for @actionContinue.
  ///
  /// In it, this message translates to:
  /// **'Continua'**
  String get actionContinue;

  /// No description provided for @actionBack.
  ///
  /// In it, this message translates to:
  /// **'Indietro'**
  String get actionBack;

  /// No description provided for @actionArchive.
  ///
  /// In it, this message translates to:
  /// **'Archivia'**
  String get actionArchive;

  /// No description provided for @actionRestore.
  ///
  /// In it, this message translates to:
  /// **'Ripristina'**
  String get actionRestore;

  /// No description provided for @actionAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get actionAdd;

  /// No description provided for @actionDiscard.
  ///
  /// In it, this message translates to:
  /// **'Esci senza salvare'**
  String get actionDiscard;

  /// No description provided for @actionKeepEditing.
  ///
  /// In it, this message translates to:
  /// **'Continua a modificare'**
  String get actionKeepEditing;

  /// No description provided for @actionMore.
  ///
  /// In it, this message translates to:
  /// **'Altre azioni'**
  String get actionMore;

  /// No description provided for @navHome.
  ///
  /// In it, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAssets.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio'**
  String get navAssets;

  /// No description provided for @navInvestments.
  ///
  /// In it, this message translates to:
  /// **'Investimenti'**
  String get navInvestments;

  /// No description provided for @navHistory.
  ///
  /// In it, this message translates to:
  /// **'Storico'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get navSettings;

  /// No description provided for @updateWealthCta.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna patrimonio'**
  String get updateWealthCta;

  /// No description provided for @updateWealthShort.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna'**
  String get updateWealthShort;

  /// No description provided for @openSettings.
  ///
  /// In it, this message translates to:
  /// **'Apri le impostazioni'**
  String get openSettings;

  /// No description provided for @greetingMorning.
  ///
  /// In it, this message translates to:
  /// **'Buongiorno'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In it, this message translates to:
  /// **'Buon pomeriggio'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In it, this message translates to:
  /// **'Buonasera'**
  String get greetingEvening;

  /// No description provided for @greetingWithName.
  ///
  /// In it, this message translates to:
  /// **'{greeting}, {name}'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @dashboardTitle.
  ///
  /// In it, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @netWorth.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio netto'**
  String get netWorth;

  /// No description provided for @grossWorth.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio lordo'**
  String get grossWorth;

  /// No description provided for @totalAssets.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get totalAssets;

  /// No description provided for @totalLiabilities.
  ///
  /// In it, this message translates to:
  /// **'Passività'**
  String get totalLiabilities;

  /// No description provided for @thisMonth.
  ///
  /// In it, this message translates to:
  /// **'questo mese'**
  String get thisMonth;

  /// No description provided for @firstUpdate.
  ///
  /// In it, this message translates to:
  /// **'Primo aggiornamento'**
  String get firstUpdate;

  /// No description provided for @unchanged.
  ///
  /// In it, this message translates to:
  /// **'invariato'**
  String get unchanged;

  /// No description provided for @distributionTitle.
  ///
  /// In it, this message translates to:
  /// **'Dove sono i tuoi soldi'**
  String get distributionTitle;

  /// No description provided for @distributionEmpty.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi delle attività per vedere come è distribuito il tuo patrimonio.'**
  String get distributionEmpty;

  /// No description provided for @otherCategory.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get otherCategory;

  /// No description provided for @chartSinglePoint.
  ///
  /// In it, this message translates to:
  /// **'Il grafico prenderà forma dal prossimo aggiornamento.'**
  String get chartSinglePoint;

  /// No description provided for @reminderMessage.
  ///
  /// In it, this message translates to:
  /// **'È ora di aggiornare il tuo patrimonio.'**
  String get reminderMessage;

  /// No description provided for @reminderAction.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna ora'**
  String get reminderAction;

  /// No description provided for @emptyDashboardTitle.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora nessun aggiornamento.'**
  String get emptyDashboardTitle;

  /// No description provided for @emptyDashboardMessage.
  ///
  /// In it, this message translates to:
  /// **'Inserisci i valori di oggi: da qui in poi vedrai crescere il grafico.'**
  String get emptyDashboardMessage;

  /// No description provided for @emptyDashboardAction.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il primo patrimonio'**
  String get emptyDashboardAction;

  /// No description provided for @recentUpdates.
  ///
  /// In it, this message translates to:
  /// **'Ultimi aggiornamenti'**
  String get recentUpdates;

  /// No description provided for @seeAll.
  ///
  /// In it, this message translates to:
  /// **'Vedi tutti'**
  String get seeAll;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In it, this message translates to:
  /// **'3M'**
  String get rangeThreeMonths;

  /// No description provided for @rangeSixMonths.
  ///
  /// In it, this message translates to:
  /// **'6M'**
  String get rangeSixMonths;

  /// No description provided for @rangeOneYear.
  ///
  /// In it, this message translates to:
  /// **'1A'**
  String get rangeOneYear;

  /// No description provided for @rangeThreeYears.
  ///
  /// In it, this message translates to:
  /// **'3A'**
  String get rangeThreeYears;

  /// No description provided for @rangeAll.
  ///
  /// In it, this message translates to:
  /// **'Tutto'**
  String get rangeAll;

  /// No description provided for @rangeThreeMonthsLong.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 3 mesi'**
  String get rangeThreeMonthsLong;

  /// No description provided for @rangeSixMonthsLong.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 6 mesi'**
  String get rangeSixMonthsLong;

  /// No description provided for @rangeOneYearLong.
  ///
  /// In it, this message translates to:
  /// **'Ultimo anno'**
  String get rangeOneYearLong;

  /// No description provided for @rangeThreeYearsLong.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 3 anni'**
  String get rangeThreeYearsLong;

  /// No description provided for @rangeAllLong.
  ///
  /// In it, this message translates to:
  /// **'Tutto lo storico'**
  String get rangeAllLong;

  /// No description provided for @chartSemantics.
  ///
  /// In it, this message translates to:
  /// **'{title}: da {startValue} a {startMonth} a {endValue} a {endMonth}'**
  String chartSemantics(
    String title,
    String startValue,
    String startMonth,
    String endValue,
    String endMonth,
  );

  /// No description provided for @shareOfTotal.
  ///
  /// In it, this message translates to:
  /// **'{percent} del totale'**
  String shareOfTotal(String percent);

  /// No description provided for @trendUp.
  ///
  /// In it, this message translates to:
  /// **'in aumento di {amount}'**
  String trendUp(String amount);

  /// No description provided for @trendDown.
  ///
  /// In it, this message translates to:
  /// **'in calo di {amount}'**
  String trendDown(String amount);

  /// No description provided for @assetsTitle.
  ///
  /// In it, this message translates to:
  /// **'Patrimonio'**
  String get assetsTitle;

  /// No description provided for @assetsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Valori dell\'aggiornamento di {month}'**
  String assetsSubtitle(String month);

  /// No description provided for @assetsSubtitleNone.
  ///
  /// In it, this message translates to:
  /// **'Nessun aggiornamento salvato: i valori compariranno dopo il primo.'**
  String get assetsSubtitleNone;

  /// No description provided for @newItem.
  ///
  /// In it, this message translates to:
  /// **'Nuova voce'**
  String get newItem;

  /// No description provided for @newCategory.
  ///
  /// In it, this message translates to:
  /// **'Nuova categoria'**
  String get newCategory;

  /// No description provided for @editItem.
  ///
  /// In it, this message translates to:
  /// **'Modifica voce'**
  String get editItem;

  /// No description provided for @editCategory.
  ///
  /// In it, this message translates to:
  /// **'Modifica categoria'**
  String get editCategory;

  /// No description provided for @nameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get nameLabel;

  /// No description provided for @itemNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Conto corrente'**
  String get itemNameHint;

  /// No description provided for @categoryLabel.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get categoryLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In it, this message translates to:
  /// **'Es. Liquidità'**
  String get categoryNameHint;

  /// No description provided for @categoryKindLabel.
  ///
  /// In it, this message translates to:
  /// **'Tipo'**
  String get categoryKindLabel;

  /// No description provided for @kindAsset.
  ///
  /// In it, this message translates to:
  /// **'Attività'**
  String get kindAsset;

  /// No description provided for @kindLiability.
  ///
  /// In it, this message translates to:
  /// **'Passività'**
  String get kindLiability;

  /// No description provided for @isInvestmentLabel.
  ///
  /// In it, this message translates to:
  /// **'Conta come investimento'**
  String get isInvestmentLabel;

  /// No description provided for @isInvestmentHelp.
  ///
  /// In it, this message translates to:
  /// **'Le voci di questa categoria compaiono nella sezione Investimenti.'**
  String get isInvestmentHelp;

  /// No description provided for @kindLockedHelp.
  ///
  /// In it, this message translates to:
  /// **'Il tipo non si può cambiare dopo la creazione.'**
  String get kindLockedHelp;

  /// No description provided for @archiveHint.
  ///
  /// In it, this message translates to:
  /// **'Archiviare non cancella lo storico: la voce non comparirà più nei prossimi aggiornamenti.'**
  String get archiveHint;

  /// No description provided for @archivedTitle.
  ///
  /// In it, this message translates to:
  /// **'Archiviati'**
  String get archivedTitle;

  /// No description provided for @archivedBadge.
  ///
  /// In it, this message translates to:
  /// **'Archiviata'**
  String get archivedBadge;

  /// No description provided for @deleteItemTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la voce?'**
  String get deleteItemTitle;

  /// No description provided for @deleteItemMessage.
  ///
  /// In it, this message translates to:
  /// **'La voce sparirà dall\'elenco. I valori già salvati negli aggiornamenti passati restano nello storico.'**
  String get deleteItemMessage;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare la categoria?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In it, this message translates to:
  /// **'Si può eliminare solo una categoria senza voci. Gli aggiornamenti passati non cambiano.'**
  String get deleteCategoryMessage;

  /// No description provided for @emptyCatalogTitle.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora nessuna voce.'**
  String get emptyCatalogTitle;

  /// No description provided for @emptyCatalogMessage.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi i conti, gli investimenti, i beni e i debiti che vuoi seguire.'**
  String get emptyCatalogMessage;

  /// No description provided for @categoryEmptyItems.
  ///
  /// In it, this message translates to:
  /// **'Nessuna voce in questa categoria.'**
  String get categoryEmptyItems;

  /// No description provided for @reorderHint.
  ///
  /// In it, this message translates to:
  /// **'Trascina le voci per riordinarle. Usa le frecce per spostare le categorie.'**
  String get reorderHint;

  /// No description provided for @moveUp.
  ///
  /// In it, this message translates to:
  /// **'Sposta su'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In it, this message translates to:
  /// **'Sposta giù'**
  String get moveDown;

  /// No description provided for @dragToReorder.
  ///
  /// In it, this message translates to:
  /// **'Trascina per riordinare'**
  String get dragToReorder;

  /// No description provided for @investmentBadge.
  ///
  /// In it, this message translates to:
  /// **'Investimento'**
  String get investmentBadge;

  /// No description provided for @validationRequired.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get validationRequired;

  /// No description provided for @validationTooLong.
  ///
  /// In it, this message translates to:
  /// **'Massimo {max} caratteri'**
  String validationTooLong(int max);

  /// No description provided for @itemCategoryMissing.
  ///
  /// In it, this message translates to:
  /// **'Crea prima una categoria.'**
  String get itemCategoryMissing;

  /// No description provided for @updateTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiorna patrimonio'**
  String get updateTitle;

  /// No description provided for @editUpdateTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica aggiornamento'**
  String get editUpdateTitle;

  /// No description provided for @prefilledHint.
  ///
  /// In it, this message translates to:
  /// **'Valori del mese scorso già inseriti: modifica solo quello che è cambiato.'**
  String get prefilledHint;

  /// No description provided for @editingExistingHint.
  ///
  /// In it, this message translates to:
  /// **'Stai modificando l\'aggiornamento di {month}.'**
  String editingExistingHint(String month);

  /// No description provided for @firstUpdateHint.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il valore attuale di ogni voce. Per i debiti, quanto resta da pagare.'**
  String get firstUpdateHint;

  /// No description provided for @addItem.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi voce'**
  String get addItem;

  /// No description provided for @saveUpdate.
  ///
  /// In it, this message translates to:
  /// **'Salva aggiornamento'**
  String get saveUpdate;

  /// No description provided for @savedMessage.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento salvato'**
  String get savedMessage;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In it, this message translates to:
  /// **'Uscire senza salvare?'**
  String get unsavedChangesTitle;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In it, this message translates to:
  /// **'Le modifiche a questo aggiornamento andranno perse.'**
  String get unsavedChangesMessage;

  /// No description provided for @previousMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese precedente'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In it, this message translates to:
  /// **'Mese successivo'**
  String get nextMonth;

  /// No description provided for @summaryTitle.
  ///
  /// In it, this message translates to:
  /// **'Riepilogo'**
  String get summaryTitle;

  /// No description provided for @keyboardHints.
  ///
  /// In it, this message translates to:
  /// **'Tab: campo successivo · Ctrl/⌘+S: salva · Esc: chiudi'**
  String get keyboardHints;

  /// No description provided for @noItemsToUpdate.
  ///
  /// In it, this message translates to:
  /// **'Non hai voci attive. Aggiungine una per iniziare.'**
  String get noItemsToUpdate;

  /// No description provided for @amountFieldLabel.
  ///
  /// In it, this message translates to:
  /// **'Importo di {name}'**
  String amountFieldLabel(String name);

  /// No description provided for @amountInvalid.
  ///
  /// In it, this message translates to:
  /// **'Importo non valido'**
  String get amountInvalid;

  /// No description provided for @amountNegative.
  ///
  /// In it, this message translates to:
  /// **'Scrivi un numero positivo: le passività si inseriscono senza segno.'**
  String get amountNegative;

  /// No description provided for @amountTooManyDecimals.
  ///
  /// In it, this message translates to:
  /// **'Usa al massimo due decimali.'**
  String get amountTooManyDecimals;

  /// No description provided for @amountTooLarge.
  ///
  /// In it, this message translates to:
  /// **'Importo troppo grande'**
  String get amountTooLarge;

  /// No description provided for @fixErrorsBeforeSaving.
  ///
  /// In it, this message translates to:
  /// **'Correggi i campi segnalati prima di salvare.'**
  String get fixErrorsBeforeSaving;

  /// No description provided for @monthChangeTitle.
  ///
  /// In it, this message translates to:
  /// **'Cambiare mese?'**
  String get monthChangeTitle;

  /// No description provided for @monthChangeMessage.
  ///
  /// In it, this message translates to:
  /// **'I valori che hai inserito per questo mese non sono ancora salvati e andranno persi.'**
  String get monthChangeMessage;

  /// No description provided for @changeMonth.
  ///
  /// In it, this message translates to:
  /// **'Cambia mese'**
  String get changeMonth;

  /// No description provided for @historyTitle.
  ///
  /// In it, this message translates to:
  /// **'Storico'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Nessun aggiornamento salvato.'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In it, this message translates to:
  /// **'Ogni mese che aggiorni comparirà qui.'**
  String get historyEmptyMessage;

  /// No description provided for @selectUpdateHint.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un aggiornamento per vedere il dettaglio.'**
  String get selectUpdateHint;

  /// No description provided for @editValues.
  ///
  /// In it, this message translates to:
  /// **'Modifica valori'**
  String get editValues;

  /// No description provided for @deleteUpdate.
  ///
  /// In it, this message translates to:
  /// **'Elimina aggiornamento'**
  String get deleteUpdate;

  /// No description provided for @deleteUpdateTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare l\'aggiornamento di {month}?'**
  String deleteUpdateTitle(String month);

  /// No description provided for @deleteUpdateMessage.
  ///
  /// In it, this message translates to:
  /// **'I valori di questo mese verranno cancellati. Gli altri mesi non cambiano.'**
  String get deleteUpdateMessage;

  /// No description provided for @updateDeleted.
  ///
  /// In it, this message translates to:
  /// **'Aggiornamento eliminato'**
  String get updateDeleted;

  /// No description provided for @updateNotFound.
  ///
  /// In it, this message translates to:
  /// **'Questo aggiornamento non esiste più.'**
  String get updateNotFound;

  /// No description provided for @investmentsTitle.
  ///
  /// In it, this message translates to:
  /// **'Investimenti'**
  String get investmentsTitle;

  /// No description provided for @investmentsValue.
  ///
  /// In it, this message translates to:
  /// **'Valore investimenti'**
  String get investmentsValue;

  /// No description provided for @monthlyChange.
  ///
  /// In it, this message translates to:
  /// **'Questo mese'**
  String get monthlyChange;

  /// No description provided for @lastMonthChange.
  ///
  /// In it, this message translates to:
  /// **'Ultimo mese'**
  String get lastMonthChange;

  /// No description provided for @yearlyChange.
  ///
  /// In it, this message translates to:
  /// **'Ultimi 12 mesi'**
  String get yearlyChange;

  /// No description provided for @sinceMonth.
  ///
  /// In it, this message translates to:
  /// **'Da {month}'**
  String sinceMonth(String month);

  /// No description provided for @breakdownTitle.
  ///
  /// In it, this message translates to:
  /// **'Ripartizione'**
  String get breakdownTitle;

  /// No description provided for @investmentsChartTitle.
  ///
  /// In it, this message translates to:
  /// **'Valore degli investimenti'**
  String get investmentsChartTitle;

  /// No description provided for @investmentsEmptyTitle.
  ///
  /// In it, this message translates to:
  /// **'Non hai ancora voci di investimento.'**
  String get investmentsEmptyTitle;

  /// No description provided for @investmentsEmptyMessage.
  ///
  /// In it, this message translates to:
  /// **'Nella sezione Patrimonio segna una categoria come investimento per vederla qui.'**
  String get investmentsEmptyMessage;

  /// No description provided for @goToAssets.
  ///
  /// In it, this message translates to:
  /// **'Vai a Patrimonio'**
  String get goToAssets;

  /// No description provided for @noInvestmentValues.
  ///
  /// In it, this message translates to:
  /// **'Nessun valore di investimento nell\'ultimo aggiornamento.'**
  String get noInvestmentValues;

  /// No description provided for @loginTitle.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Bentornato. Inserisci le tue credenziali.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In it, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In it, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @forgotPassword.
  ///
  /// In it, this message translates to:
  /// **'Password dimenticata?'**
  String get forgotPassword;

  /// No description provided for @loginAction.
  ///
  /// In it, this message translates to:
  /// **'Accedi'**
  String get loginAction;

  /// No description provided for @noAccount.
  ///
  /// In it, this message translates to:
  /// **'Non hai un account?'**
  String get noAccount;

  /// No description provided for @signUpLink.
  ///
  /// In it, this message translates to:
  /// **'Registrati'**
  String get signUpLink;

  /// No description provided for @tryDemo.
  ///
  /// In it, this message translates to:
  /// **'Prova la demo'**
  String get tryDemo;

  /// No description provided for @signUpTitle.
  ///
  /// In it, this message translates to:
  /// **'Crea il tuo account'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Bastano un\'email e una password.'**
  String get signUpSubtitle;

  /// No description provided for @signUpAction.
  ///
  /// In it, this message translates to:
  /// **'Crea account'**
  String get signUpAction;

  /// No description provided for @haveAccount.
  ///
  /// In it, this message translates to:
  /// **'Hai già un account?'**
  String get haveAccount;

  /// No description provided for @passwordHelper.
  ///
  /// In it, this message translates to:
  /// **'Almeno 8 caratteri'**
  String get passwordHelper;

  /// No description provided for @confirmEmailTitle.
  ///
  /// In it, this message translates to:
  /// **'Controlla la tua email'**
  String get confirmEmailTitle;

  /// No description provided for @confirmEmailMessage.
  ///
  /// In it, this message translates to:
  /// **'Ti abbiamo inviato un link di conferma a {email}. Aprilo per attivare l\'account, poi accedi.'**
  String confirmEmailMessage(String email);

  /// No description provided for @backToLogin.
  ///
  /// In it, this message translates to:
  /// **'Torna all\'accesso'**
  String get backToLogin;

  /// No description provided for @forgotTitle.
  ///
  /// In it, this message translates to:
  /// **'Recupera la password'**
  String get forgotTitle;

  /// No description provided for @forgotMessage.
  ///
  /// In it, this message translates to:
  /// **'Inserisci l\'email del tuo account: ti invieremo un link per scegliere una nuova password.'**
  String get forgotMessage;

  /// No description provided for @forgotAction.
  ///
  /// In it, this message translates to:
  /// **'Invia link'**
  String get forgotAction;

  /// No description provided for @forgotSentMessage.
  ///
  /// In it, this message translates to:
  /// **'Se esiste un account con {email}, riceverai a breve un\'email con il link.'**
  String forgotSentMessage(String email);

  /// No description provided for @resetTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get resetTitle;

  /// No description provided for @resetMessage.
  ///
  /// In it, this message translates to:
  /// **'Scegli una nuova password per il tuo account.'**
  String get resetMessage;

  /// No description provided for @newPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Nuova password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In it, this message translates to:
  /// **'Ripeti la password'**
  String get confirmPasswordLabel;

  /// No description provided for @resetAction.
  ///
  /// In it, this message translates to:
  /// **'Salva password'**
  String get resetAction;

  /// No description provided for @passwordUpdated.
  ///
  /// In it, this message translates to:
  /// **'Password aggiornata'**
  String get passwordUpdated;

  /// No description provided for @invalidEmail.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un\'email valida'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In it, this message translates to:
  /// **'La password deve avere almeno 8 caratteri'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In it, this message translates to:
  /// **'Le password non coincidono'**
  String get passwordsDoNotMatch;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento al server non è configurato. Puoi provare l\'app in modalità demo.'**
  String get supabaseNotConfigured;

  /// No description provided for @showPassword.
  ///
  /// In it, this message translates to:
  /// **'Mostra password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In it, this message translates to:
  /// **'Nascondi password'**
  String get hidePassword;

  /// No description provided for @welcomeTitle.
  ///
  /// In it, this message translates to:
  /// **'Benvenuto'**
  String get welcomeTitle;

  /// No description provided for @start.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get start;

  /// No description provided for @stepOf.
  ///
  /// In it, this message translates to:
  /// **'Passo {current} di {total}'**
  String stepOf(int current, int total);

  /// No description provided for @chooseItemsTitle.
  ///
  /// In it, this message translates to:
  /// **'Cosa possiedi?'**
  String get chooseItemsTitle;

  /// No description provided for @chooseItemsMessage.
  ///
  /// In it, this message translates to:
  /// **'Scegli le voci da seguire. Potrai cambiarle quando vuoi.'**
  String get chooseItemsMessage;

  /// No description provided for @chooseAtLeastOne.
  ///
  /// In it, this message translates to:
  /// **'Scegli almeno una voce per continuare.'**
  String get chooseAtLeastOne;

  /// No description provided for @firstValuesTitle.
  ///
  /// In it, this message translates to:
  /// **'Quanto vale oggi?'**
  String get firstValuesTitle;

  /// No description provided for @firstValuesMessage.
  ///
  /// In it, this message translates to:
  /// **'Scrivi il valore attuale di ogni voce. Per i debiti, quanto resta da pagare.'**
  String get firstValuesMessage;

  /// No description provided for @finishOnboarding.
  ///
  /// In it, this message translates to:
  /// **'Salva e vai alla home'**
  String get finishOnboarding;

  /// No description provided for @catLiquidity.
  ///
  /// In it, this message translates to:
  /// **'Liquidità'**
  String get catLiquidity;

  /// No description provided for @catInvestments.
  ///
  /// In it, this message translates to:
  /// **'Investimenti'**
  String get catInvestments;

  /// No description provided for @catRealEstate.
  ///
  /// In it, this message translates to:
  /// **'Immobili'**
  String get catRealEstate;

  /// No description provided for @catOtherAssets.
  ///
  /// In it, this message translates to:
  /// **'Altri beni'**
  String get catOtherAssets;

  /// No description provided for @catDebts.
  ///
  /// In it, this message translates to:
  /// **'Debiti'**
  String get catDebts;

  /// No description provided for @itemCurrentAccount.
  ///
  /// In it, this message translates to:
  /// **'Conto corrente'**
  String get itemCurrentAccount;

  /// No description provided for @itemDepositAccount.
  ///
  /// In it, this message translates to:
  /// **'Conto deposito'**
  String get itemDepositAccount;

  /// No description provided for @itemCash.
  ///
  /// In it, this message translates to:
  /// **'Contanti'**
  String get itemCash;

  /// No description provided for @itemEtf.
  ///
  /// In it, this message translates to:
  /// **'ETF'**
  String get itemEtf;

  /// No description provided for @itemStocks.
  ///
  /// In it, this message translates to:
  /// **'Azioni'**
  String get itemStocks;

  /// No description provided for @itemBonds.
  ///
  /// In it, this message translates to:
  /// **'Obbligazioni'**
  String get itemBonds;

  /// No description provided for @itemCrypto.
  ///
  /// In it, this message translates to:
  /// **'Crypto'**
  String get itemCrypto;

  /// No description provided for @itemPensionFund.
  ///
  /// In it, this message translates to:
  /// **'Fondo pensione'**
  String get itemPensionFund;

  /// No description provided for @itemHome.
  ///
  /// In it, this message translates to:
  /// **'Casa'**
  String get itemHome;

  /// No description provided for @itemCar.
  ///
  /// In it, this message translates to:
  /// **'Auto'**
  String get itemCar;

  /// No description provided for @itemMortgage.
  ///
  /// In it, this message translates to:
  /// **'Mutuo'**
  String get itemMortgage;

  /// No description provided for @itemLoan.
  ///
  /// In it, this message translates to:
  /// **'Prestito'**
  String get itemLoan;

  /// No description provided for @itemCreditCard.
  ///
  /// In it, this message translates to:
  /// **'Carta di credito'**
  String get itemCreditCard;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In it, this message translates to:
  /// **'Profilo'**
  String get profileSection;

  /// No description provided for @displayNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In it, this message translates to:
  /// **'Il nome da mostrare nella home'**
  String get displayNameHint;

  /// No description provided for @appearanceSection.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get appearanceSection;

  /// No description provided for @themeLabel.
  ///
  /// In it, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get themeDark;

  /// No description provided for @securitySection.
  ///
  /// In it, this message translates to:
  /// **'Sicurezza'**
  String get securitySection;

  /// No description provided for @changePassword.
  ///
  /// In it, this message translates to:
  /// **'Cambia password'**
  String get changePassword;

  /// No description provided for @accountSection.
  ///
  /// In it, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @signOut.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In it, this message translates to:
  /// **'Elimina account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare l\'account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In it, this message translates to:
  /// **'Tutti i tuoi dati verranno cancellati in modo definitivo: voci, categorie e aggiornamenti. L\'operazione non si può annullare.'**
  String get deleteAccountMessage;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In it, this message translates to:
  /// **'Elimina definitivamente'**
  String get deleteAccountConfirm;

  /// No description provided for @profileSaved.
  ///
  /// In it, this message translates to:
  /// **'Profilo aggiornato'**
  String get profileSaved;

  /// No description provided for @exitDemo.
  ///
  /// In it, this message translates to:
  /// **'Esci dalla demo'**
  String get exitDemo;

  /// No description provided for @demoSettingsNote.
  ///
  /// In it, this message translates to:
  /// **'Nella demo le impostazioni dell\'account non sono disponibili.'**
  String get demoSettingsNote;

  /// No description provided for @signedInAs.
  ///
  /// In it, this message translates to:
  /// **'Accesso effettuato come {email}'**
  String signedInAs(String email);

  /// No description provided for @demoBanner.
  ///
  /// In it, this message translates to:
  /// **'Modalità demo · dati di esempio, non salvati'**
  String get demoBanner;

  /// No description provided for @demoExit.
  ///
  /// In it, this message translates to:
  /// **'Esci'**
  String get demoExit;

  /// No description provided for @errorNetwork.
  ///
  /// In it, this message translates to:
  /// **'Non riesco a collegarmi. Controlla la connessione e riprova.'**
  String get errorNetwork;

  /// No description provided for @errorSessionExpired.
  ///
  /// In it, this message translates to:
  /// **'La sessione è scaduta. Accedi di nuovo.'**
  String get errorSessionExpired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In it, this message translates to:
  /// **'Email o password non corrette.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In it, this message translates to:
  /// **'Devi prima confermare l\'email: controlla la tua casella di posta.'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorEmailAlreadyUsed.
  ///
  /// In it, this message translates to:
  /// **'Esiste già un account con questa email.'**
  String get errorEmailAlreadyUsed;

  /// No description provided for @errorWeakPassword.
  ///
  /// In it, this message translates to:
  /// **'La password è troppo debole. Usane una più lunga o più varia.'**
  String get errorWeakPassword;

  /// No description provided for @errorSamePassword.
  ///
  /// In it, this message translates to:
  /// **'La nuova password deve essere diversa da quella attuale.'**
  String get errorSamePassword;

  /// No description provided for @errorRateLimited.
  ///
  /// In it, this message translates to:
  /// **'Troppi tentativi. Riprova tra qualche minuto.'**
  String get errorRateLimited;

  /// No description provided for @errorMonthAlreadyExists.
  ///
  /// In it, this message translates to:
  /// **'Questo mese ha già un aggiornamento.'**
  String get errorMonthAlreadyExists;

  /// No description provided for @errorCategoryNotEmpty.
  ///
  /// In it, this message translates to:
  /// **'La categoria contiene ancora delle voci. Spostale o eliminale prima.'**
  String get errorCategoryNotEmpty;

  /// No description provided for @errorNotFound.
  ///
  /// In it, this message translates to:
  /// **'L\'elemento non esiste più.'**
  String get errorNotFound;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Non hai i permessi per questa operazione.'**
  String get errorPermissionDenied;

  /// No description provided for @errorNotConfigured.
  ///
  /// In it, this message translates to:
  /// **'Il collegamento al server non è configurato.'**
  String get errorNotConfigured;

  /// No description provided for @errorInvalidData.
  ///
  /// In it, this message translates to:
  /// **'Alcuni dati non sono validi.'**
  String get errorInvalidData;

  /// No description provided for @errorServer.
  ///
  /// In it, this message translates to:
  /// **'Il server non risponde come dovrebbe. Riprova tra poco.'**
  String get errorServer;

  /// No description provided for @errorUnknown.
  ///
  /// In it, this message translates to:
  /// **'Qualcosa è andato storto. Riprova.'**
  String get errorUnknown;

  /// No description provided for @saveFailed.
  ///
  /// In it, this message translates to:
  /// **'Salvataggio non riuscito. I tuoi dati sono ancora qui: riprova.'**
  String get saveFailed;

  /// No description provided for @pageNotFound.
  ///
  /// In it, this message translates to:
  /// **'Pagina non trovata.'**
  String get pageNotFound;

  /// No description provided for @goHome.
  ///
  /// In it, this message translates to:
  /// **'Torna alla home'**
  String get goHome;

  /// No description provided for @loading.
  ///
  /// In it, this message translates to:
  /// **'Caricamento…'**
  String get loading;

  /// No description provided for @demoModeLabel.
  ///
  /// In it, this message translates to:
  /// **'Modalità demo'**
  String get demoModeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
