import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Supported Locales ro'yxatini yangiladim, country kodlarini qo'shdim
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('uz', 'UZ'), // Uzbek
    Locale('ru', 'RU'), // Russian
  ];

  Map<String, String> _getLocalizedValues() {
    switch (locale.languageCode) {
      case 'uz':
        return {
          'authTitle': 'Kirish va Ro‘yxatdan o‘tish',
          'loginTab': 'Kirish',
          'registerTab': 'Ro‘yxatdan o‘tish',
          'email': 'Elektron pochta',
          'password': 'Parol',
          'username': 'Foydalanuvchi nomi',
          'newPhone': 'Yangi telefon raqami (+998)',
          'phone': 'Telefon raqami',
          'smsCode': 'SMS kodi',
          'fillAllFields': 'Iltimos, barcha maydonlarni to‘ldiring',
          'loginButton': 'Kirish',
          'verifyAndRegisterButton':
              'Telefonni tasdiqlash va ro‘yxatdan o‘tish',
          'verifyCodeButton': 'Kodni tasdiqlash va ro‘yxatdan o‘tish',
          'loginSuccess': 'Kirish muvaffaqiyatli',
          'registerSuccess': 'Ro‘yxatdan o‘tish muvaffaqiyatli',
          'emailRegisterSuccess':
              'Elektron pochta orqali ro‘yxatdan o‘tish muvaffaqiyatli',
          'error': 'Xatolik',
          'smsCodeSent': 'SMS kodi yuborildi',
          'enterSmsCode': 'SMS kodini kiriting',
          'userNotFound': 'Foydalanuvchi topilmadi',
          'emailLinkError': 'Elektron pochtani ulashda xatolik',
          'updateButton': 'Ma‘lumotlarni yangilash',
          'profileTitle': 'Profil',
          'userDataTab': 'Foydalanuvchi ma‘lumotlari',
          'editDataTab': 'Ma‘lumotlarni tahrirlash',
          'logout': 'Chiqish',
          'deleteAccount': 'Hisobni o‘chirish',
          'accountDeleted': 'Hisob o‘chirildi',
          'notSet': 'O‘rnatilmagan',
          'enterNewEmail': 'Yangi elektron pochtani kiriting',
          'enterNewPassword': 'Yangi parolni kiriting',
          'enterNewPhone': 'Yangi telefon raqamini kiriting',
          'enterUsername': 'Foydalanuvchi nomini kiriting',
          'emailUpdated': 'Elektron pochta yangilandi',
          'passwordUpdated': 'Parol yangilandi',
          'phoneUpdated': 'Telefon raqami yangilandi',
          'usernameUpdated': 'Foydalanuvchi nomi yangilandi',
          'updateError': 'Yangilashda xatolik',
          'phoneVerificationError': 'Telefon tasdiqlashda xatolik',
          'emailNotVerified': 'Elektron pochta tasdiqlanmagan',
          'pickPhoto': 'Profil rasmini tanlash',
          'uploadPhoto': 'Profil rasmini yuklash',
          'photoUpdated': 'Profil rasmi yangilandi',
          'adminSection': 'Admin paneli',
          'userBlocked': 'Foydalanuvchi bloklandi',
          'userUnblocked': 'Foydalanuvchi blokdan chiqarildi',
          'selectDataToEdit': 'Tahrir qilish uchun ma‘lumotni tanlang',
          'updateEmailButton': 'Elektron pochtani yangilash',
          'updatePasswordButton': 'Parolni yangilash',
          'updatePhoneButton': 'Telefon raqamini yangilash',
          'updateUsernameButton': 'Foydalanuvchi nomini yangilash',
          'verifyNewPhoneButton': 'Yangi telefonni tasdiqlash',
          'profilePhoto': 'Profil rasmi',
          'forgotPassword': 'Parolni unutdingizmi?',
          'resetPassword': 'Parolni tiklash',
          'enterEmail': 'Elektron pochtani kiriting',
          'cancel': 'Bekor qilish',
          'sendResetLink': 'Tiklash havolasini yuborish',
          'resetEmailSent': 'Parolni tiklash uchun elektron pochta yuborildi',
          'resetEmailError': 'Parolni tiklashda xatolik',
          'continueWithoutLogin': 'Kirishsiz davom etish',
          'homeTitle': 'Bosh sahifa',
          'settings': 'Sozlamalar',
          'language': 'Til',
          'expensesAndIncome': 'Xarajatlar va Daromadlar',
          'transactionTitle': 'Xarajatlar/Daromadlar',
          'transactionPlaceholder':
              'Xarajatlar va daromadlarni boshqarish sahifasi',
          'usePhoneLogin': 'Telefon raqami bilan kirish',
          'loginRequired': 'Bu funksiyadan foydalanish uchun kirish kerak',
          'loading': 'Yuklanmoqda...',
          'budgetOverview': 'Byudjet',
          'transactionHistory': 'Tarix',
          'enterTransaction': 'Kiritish',
          'selectPeriod': 'Davrni Tanlash',
          'totalIncome': 'Jami Daromad',
          'totalExpenses': 'Jami Xarajatlar',
          'balance': 'Balans',
          'amount': 'Miqdor',
          'transactionType': 'Tranzaksiya Turi',
          'saveTransaction': 'Tranzaksiyani Saqlash',
          'manageTypes': 'Turlarni Boshqarish',
          'newType': 'Yangi Tranzaksiya Turi',
          'addType': 'Tur Qo‘shish',
          'expense': 'Xarajat',
          'income': 'Daromad',
          'transactionSaved': 'Tranzaksiya saqlandi',
          'notificationsTitle': 'Xabarnomalar',
          'newTransaction': 'Yangi Tranzaksiya',
          'newTransactionBody':
              'Sizda ko‘rib chiqish uchun yangi qarz tranzaksiyasi bor.',
          'confirmTransaction': 'Tranzaksiyani Tasdiqlash',
          'cancelTransaction': 'Tranzaksiyani Bekor Qilish',
          'transactionDetails': 'Tranzaksiya Tafsilotlari',
          'transactionConfirmed': 'Tranzaksiya tasdiqlandi',
          'transactionCancelled': 'Tranzaksiya bekor qilindi',
          'notificationSent': 'Xabarnoma yuborildi',
          'status': 'Holat',
          'type': 'Tur',
          'category': 'Kategoriya',
          'date': 'Sana',
          'recipientNotFound': 'Qabul qiluvchi topilmadi',
          'multipleRecipients':
              'Bu telefon raqami uchun bir nechta foydalanuvchi topildi',
          'sendNotification': 'Bildirishnoma yuborish?',
          'details': 'Tafsilotlar',
          'yes': 'Ha',
          'no': 'Yo‘q',
          'noData': "Ma'lumot yo‘q",
          'bank_loan': "Kredit",
          'loan_to_friends': "Qarz berildi",
          'loan_from_friends': "Qarz olindi",
          'salary': "Oylik maosh",
          'selectRole': 'Rol tanlang', // NEW
          'client': 'Mijoz', // NEW
          'driver': 'Haydovchi', // NEW
          'carNumber': 'Mashina raqami', // NEW
          'carType': 'Mashina turi', // NEW
          'invitationCanceled': 'Taklif bekor qilindi',
          'viewPrimaryTransactions': 'Asosiy tranzaksiyalarni ko‘rish',
          'noNotifications': 'Xabarnomalar yo‘q',
          'checkFirestore': 'Firestore-ni tekshiring',
          'newEmail': 'Yangi elektron pochta',
          'newPassword': 'Yangi parol',
          'pending': 'Kutilmoqda',
          'confirmed': 'Tasdiqlangan',
          'rejected': 'Rad etilgan',
          'confirm': 'Tasdiqlash',
          'reject': 'Rad etish',
          'notificationStatusUpdated': 'Xabarnoma holati yangilandi',
          'updateProfile': 'Profilni yangilash',
          'profileUpdated': 'Profil yangilandi',
          'showDetails': 'Tafsilotlarni ko‘rsatish',
          'transactionRejected': 'Tranzaksiya rad etildi',
          'showExpenses': 'Xarajatlarni ko‘rsatish',
          'showIncomes': 'Daromadlarni ko‘rsatish',
          'acceptAction': 'Qabul qilish amali',
          'accept': 'Qabul qilish',
          'transaction': 'Tranzaksiya',
          'notifications': 'Xabarnomalar',
          'isExpense': 'Bu xarajatmi?',
          'notificationStatus': 'Xabarnoma holati',
          'notificationBody': 'Xabarnoma matni',
          'close': 'Yopish',
          'enterValidPhone': 'Yaroqli telefon raqamini kiriting',
          'cannotInviteSelf': 'O\'zingizni taklif qila olmaysiz',
          'familyMemberInvited': 'Oilaviy a\'zo taklif qilindi',
          'transactionDeleted': 'Tranzaksiya o‘chirildi',
          'transactionUpdated': 'Tranzaksiya yangilandi',
          'transactionInvolvingYou': 'Siz ishtirok etgan tranzaksiya',
          'acceptToSync': 'Sinxronizatsiya qilish uchun qabul qiling',
          'familyMembers': 'Oilaviy a\'zolar',
          'changedBy': 'O‘zgartirdi',
          'inviteFamilyMember': 'Oilaviy a\'zoni taklif qilish',
          'invite': 'Taklif qilish',
          'noFamilyMembers': 'Oilaviy a\'zolar yo‘q',
          'invitations': 'Takliflar',
          'noInvitations': 'Takliflar yo‘q',
          'invitationFrom': 'Taklif qildi',
          // New strings for HomePage
          'welcomeDriver': 'Xush kelibsiz, haydovchi!', // NEW
          'driverDetails': 'Sizning ma\'lumotlaringiz:', // NEW
          'viewAvailableRides': 'Mavjud sayohatlarni ko\'rish', // NEW
          'viewYourShipments': 'Yuklaringizni ko\'rish', // NEW
          'goOnline': 'Onlayn bo\'lish', // NEW
          'driverUtilities': 'Haydovchi uchun imkoniyatlar:', // NEW
          'welcomeClient': 'Xush kelibsiz, mijoz!', // NEW
          'clientDetails': 'Sizning ma\'lumotlaringiz:', // NEW
          'bookARide': 'Sayohat buyurtma qilish', // NEW
          'viewYourRides': 'Sayohatlaringizni ko\'rish', // NEW
          'trackShipment': 'Yukni kuzatish', // NEW
          'clientUtilities': 'Mijoz uchun imkoniyatlar:', // NEW
          'welcomeGuest': 'Xush kelibsiz, mehmon!', // NEW
          'guestUtilities': 'Mehmon uchun imkoniyatlar:', // NEW
          'signUpNow': 'Hozir ro\'yxatdan o\'ting', // NEW
          'loginNow': 'Hozir kiring', // NEW
          'learnMore': 'Batafsil ma\'lumot', // NEW
          'featureComingSoon': 'Funksiya tez orada paydo bo\'ladi!', // NEW
          // NEW strings for Add Ride & My Rides
          'addRide': 'Sayohat qo\'shish',
          'myRides': 'Mening sayohatlarim',
          'selectDateTime': 'Iltimos, sana va vaqtni tanlang',
          'rideAddedSuccessfully': 'Sayohat muvaffaqiyatli qo\'shildi!',
          'rideDetails': 'Sayohat tafsilotlari',
          'selectDate': 'Sanani tanlang',
          'selectTime': 'Vaqtni tanlang',
          'fromWhere': 'Qayerdan',
          'toWhere': 'Qayerga',
          'price': 'Narxi',
          'neededPassengers': 'Kerakli yo\'lovchilar soni',
          'additionalPhoneNumber': 'Qo\'shimcha telefon raqami',
          'deliversObjects': 'Yuk yetkazib beradimi?',
          'isDailyRide': 'Har kuni?',
          'addRideButton': 'Sayohatni qo\'shish',
          'enterFromLocation': 'Iltimos, jo\'nash manzilini kiriting',
          'enterToLocation': 'Iltimos, borish manzilini kiriting',
          'enterPrice': 'Iltimos, narxni kiriting',
          'enterValidPrice': 'Iltimos, to\'g\'ri raqam kiriting',
          'enterPassengerCount': 'Iltimos, yo\'lovchilar sonini kiriting',
          'enterValidNumber': 'Iltimos, to\'g\'ri raqam kiriting',
          'noRidesFound': 'Sayohatlar topilmadi.',
          'rideStatusUpdated': 'Sayohat holati yangilandi!',
          'activeStatus': 'Faol',
          'frozenStatus': 'Muzlatilgan',
          'freezeButton': 'Muzlatish',
          'activateButton': 'Faollashtirish',
          'confirmDelete': 'O\'chirishni tasdiqlash',
          'confirmDeleteRide':
              'Haqiqatan ham ushbu sayohatni o\'chirmoqchimisiz?',
          'delete': 'O\'chirish',
          'rideDeletedSuccessfully': 'Sayohat muvaffaqiyatli o\'chirildi!',
          // NEW strings for Book Ride Screen
          'getRideButton': 'Sayohatni olish',
          'sendOffer': 'Taklif yuborish',
          'requestedPassengers': 'So\'ralgan yo\'lovchilar',
          'isShipmentRequest': 'Yuk yetkazib berish so\'rovi?',
          'yourComment': 'Sizning izohingiz (majburiy emas)',
          'offerSentSuccessfully': 'Taklif muvaffaqiyatli yuborildi!',
          'failedToSendOffer': 'Taklif yuborishda xato yuz berdi',
          'noActiveRides': 'Faol sayohatlar topilmadi.',
          'browseRides': 'Sayohatlarni ko\'rish',
          'cancelRideButton': 'Sayohatni bekor qilish', // NEW
          'offerCancelledSuccessfully':
              'Taklif muvaffaqiyatli bekor qilindi!', // NEW
          'failedToCancelOffer':
              'Taklifni bekor qilishda xato yuz berdi', // NEW
          'takeOverLocation': 'Olish joyi (majburiy emas)', // NEW
          // NEW strings for Notifications Screen (Driver Offers)
          'rideOffers': 'Sayohat takliflari', // NEW
          'generalNotifications': 'Umumiy xabarnomalar', // NEW
          'newRideOffer': 'Yangi sayohat taklifi!', // NEW
          'fromClient': 'Mijozdan', // NEW
          'offeredPrice': 'Taklif qilingan narx', // NEW
          'sentAt': 'Yuborilgan vaqti', // NEW
          'acceptOffer': 'Taklifni qabul qilish', // NEW
          'rejectOffer': 'Taklifni rad etish', // NEW
          'addCommentOptional': 'Izoh qo\'shing (majburiy emas):', // NEW
          'offerStatusUpdated': 'Taklif holati yangilandi!', // NEW
          'errorUpdatingOffer': 'Taklifni yangilashda xatolik', // NEW
          'noPendingOffers': 'Kutilayotgan sayohat takliflari yo\'q.', // NEW
          'clientComment': 'Mijoz izohi', // NEW
          // NEW strings for My Orders Screen
          'myOrders': 'Mening buyurtmalarim', // NEW
          'clientOffersTitle': 'Sizning sayohat takliflaringiz', // NEW
          'noClientOffers':
              'Siz hali hech qanday sayohat taklifi yubormagansiz.', // NEW
          'driverAcceptedOffersTitle':
              'Sizning qabul qilingan mijoz buyurtmalaringiz', // NEW
          'noDriverAcceptedOffers':
              'Sizda qabul qilingan mijoz buyurtmalari yo\'q.', // NEW
          'offerFor': 'Taklif', // NEW
          'pendingStatus': 'Kutilmoqda', // NEW
          'acceptedStatus': 'Qabul qilingan', // NEW
          'rejectedStatus': 'Rad etilgan', // NEW
          'cancelledStatus': 'Bekor qilingan', // NEW
          'unknownStatus': 'Noma\'lum', // NEW
          'driverId': 'Haydovchi ID', // NEW
          'driverPhoneNumber': 'Haydovchi telefoni', // NEW
          'respondedAt': 'Javob berilgan vaqt', // NEW
          'removeOrder': 'Buyurtmani olib tashlash', // NEW
          'confirmDeleteOffer':
              'Haqiqatan ham ushbu taklifni o\'chirmoqchimisiz?', // NEW
          'offerRemovedSuccessfully':
              'Taklif muvaffaqiyatli olib tashlandi!', // NEW
          'failedToRemoveOffer':
              'Taklifni olib tashlashda xato yuz berdi', // NEW
          'driverUsername': 'Haydovchi nomi', // NEW
          'driverInfo': 'Haydovchi ma\'lumotlari', // NEW
          'notAvailable': 'Mavjud emas', // NEW
          'loadingRideDetails': 'Sayohat tafsilotlari yuklanmoqda...', // NEW
          'notDailyRide': 'Kundalik sayohat emas', // NEW
          'filterFromLocation': 'Manzil bo\'yicha filtrlash', // NEW
          'filterToLocation': 'Manzilga filtrlash', // NEW
          'searchDriver': 'Haydovchini qidirish', // NEW
          'selectDateFilter': 'Sanani tanlash filtri', // NEW
          'clearDateFilter': 'Sanani filtrlashni tozalash', // NEW
          'filterRides': 'Filtrlash', // NEW
          'selectLocationOnMap': 'Xaritadan joylashuvni tanlash', // NEW
          'changeLocation': 'Joylashuvni o\'zgartirish', // NEW
          'selectedLocation': 'Tanlangan joylashuv', // NEW
          'latitude': 'Kenglik', // NEW
          'longitude': 'Uzunlik', // NEW
          'locationAddress': 'Manzil', // NEW
          'enterCoordinatesManually': 'Xarita tanlovini simulyatsiya qilish uchun koordinatalarni va manzilni kiriting.', // NEW
          'selectTakeOverLocation': 'Olish joyini tanlang', // NEW
          'clear': 'Tozalash', // NEW
          'select': 'Tanlash', // NEW
          'enterValidLocationData': 'Iltimos, to\'g\'ri manzil, kenglik va uzunlikni kiriting.', // NEW
          'locationSelected': 'Joylashuv tanlandi', // NEW
          'locationCleared': 'Joylashuv tanlovi tozalandi.', // NEW
          'viewOnMap': 'Xaritada ko\'rish', // NEW
          'cannotLaunchMap': 'Xaritani ishga tushirib bo\'lmadi.', // NEW
          'clearFilter': 'Filterni tozalash',
          'selectTakeOverLocation': 'Olish joyini tanlash', // NEW
          'mapSelectionInstructions': 'Google Xaritalarni oching va koordinatalar/manzilni nusxalash/joylashtiring:', // NEW
          'mapSelectionInstructionsTitle': 'Manzilni qanday tanlash kerak:', // NEW
        };
      case 'ru':
        return {
          'authTitle': 'Вход и регистрация',
          'loginTab': 'Вход',
          'registerTab': 'Регистрация',
          'email': 'Электронная почта',
          'password': 'Пароль',
          'username': 'Имя пользователя',
          'newPhone': 'Новый номер телефона (+998)',
          'phone': 'Номер телефона',
          'smsCode': 'Код из SMS',
          'fillAllFields': 'Пожалуйста, заполните все поля',
          'loginButton': 'Войти',
          'verifyAndRegisterButton': 'Подтвердить телефон и зарегистрироваться',
          'verifyCodeButton': 'Подтвердить код и зарегистрироваться',
          'loginSuccess': 'Вход успешен',
          'registerSuccess': 'Регистрация успешна',
          'emailRegisterSuccess': 'Регистрация по электронной почте успешна',
          'error': 'Ошибка',
          'smsCodeSent': 'Код SMS отправлен',
          'enterSmsCode': 'Введите код из SMS',
          'userNotFound': 'Пользователь не найден',
          'emailLinkError': 'Ошибка при привязке электронной почты',
          'updateButton': 'Обновить информацию',
          'profileTitle': 'Профиль',
          'userDataTab': 'Данные пользователя',
          'editDataTab': 'Редактировать данные',
          'logout': 'Выйти',
          'deleteAccount': 'Удалить аккаунт',
          'accountDeleted': 'Аккаунт удален',
          'notSet': 'Не указано',
          'enterNewEmail': 'Введите новый адрес электронной почты',
          'enterNewPassword': 'Введите новый пароль',
          'enterNewPhone': 'Введите новый номер телефона',
          'enterUsername': 'Введите имя пользователя',
          'emailUpdated': 'Электронная почта обновлена',
          'passwordUpdated': 'Пароль обновлен',
          'phoneUpdated': 'Номер телефона обновлен',
          'usernameUpdated': 'Имя пользователя обновлено',
          'updateError': 'Ошибка обновления',
          'phoneVerificationError': 'Ошибка подтверждения телефона',
          'emailNotVerified': 'Электронная почта не подтверждена',
          'pickPhoto': 'Выбрать фото профиля',
          'uploadPhoto': 'Загрузить фото профиля',
          'photoUpdated': 'Фото профиля обновлено',
          'adminSection': 'Панель администратора',
          'userBlocked': 'Пользователь заблокирован',
          'userUnblocked': 'Пользователь разблокирован',
          'selectDataToEdit': 'Выберите данные для редактирования',
          'updateEmailButton': 'Обновить электронную почту',
          'updatePasswordButton': 'Обновить пароль',
          'updatePhoneButton': 'Обновить номер телефона',
          'updateUsernameButton': 'Обновить имя пользователя',
          'verifyNewPhoneButton': 'Подтвердить новый телефон',
          'profilePhoto': 'Фото профиля',
          'forgotPassword': 'Забыли пароль?',
          'resetPassword': 'Сбросить пароль',
          'enterEmail': 'Введите электронную почту',
          'cancel': 'Отмена',
          'sendResetLink': 'Отправить ссылку для сброса',
          'resetEmailSent': 'Письмо для сброса пароля отправлено',
          'resetEmailError': 'Ошибка при сбросе пароля',
          'continueWithoutLogin': 'Продолжить без входа',
          'homeTitle': 'Главная',
          'settings': 'Настройки',
          'language': 'Язык',
          'expensesAndIncome': 'Расходы и доходы',
          'transactionTitle': 'Расходы/Доходы',
          'transactionPlaceholder': 'Страница управления расходами и доходами',
          'usePhoneLogin': 'Войти с номером телефона',
          'loginRequired': 'Для доступа к этой функции требуется вход',
          'loading': 'Загрузка...',
          'budgetOverview': 'Обзор бюджета',
          'transactionHistory': 'История транзакций',
          'enterTransaction': 'Ввод транзакции',
          'selectPeriod': 'Выбрать период',
          'totalIncome': 'Общий доход',
          'totalExpenses': 'Общие расходы',
          'balance': 'Баланс',
          'amount': 'Сумма',
          'transactionType': 'Тип транзакции',
          'saveTransaction': 'Сохранить транзакцию',
          'manageTypes': 'Управление типами',
          'newType': 'Новый тип транзакции',
          'addType': 'Добавить тип',
          'expense': 'Расход',
          'income': 'Доход',
          'transactionSaved': 'Транзакция сохранена',
          'notificationsTitle': 'Уведомления',
          'newTransaction': 'Новая транзакция',
          'newTransactionBody':
              'У вас есть новая транзакция по займу для рассмотрения.',
          'confirmTransaction': 'Подтвердить транзакцию',
          'cancelTransaction': 'Отменить транзакцию',
          'transactionDetails': 'Детали транзакции',
          'transactionConfirmed': 'Транзакция подтверждена',
          'transactionCancelled': 'Транзакция отменена',
          'notificationSent': 'Уведомление отправлено',
          'status': 'Статус',
          'type': 'Тип',
          'category': 'Категория',
          'date': 'Дата',
          'recipientNotFound': 'Получатель не найден',
          'multipleRecipients':
              'Для этого номера телефона найдено несколько пользователей',
          'details': 'Детали',
          'sendNotification': 'Отправить уведомление?',
          'yes': 'Да',
          'no': 'Нет',
          'noData': "Нет данных",
          'bank_loan': "Кредит",
          'loan_to_friends': "Погасить долг",
          'loan_from_friends': "Получить долг",
          'salary': "Зарплата",
          'selectRole': 'Выберите роль', // NEW
          'client': 'Клиент', // NEW
          'driver': 'Водитель', // NEW
          'carNumber': 'Номер автомобиля', // NEW
          'carType': 'Тип автомобиля', // NEW
          'invitationCanceled': 'Приглашение отменено',
          'viewPrimaryTransactions': 'Просмотр основных транзакций',
          'noNotifications': 'Нет уведомлений',
          'checkFirestore': 'Проверить Firestore',
          'newEmail': 'Новая электронная почта',
          'newPassword': 'Новый пароль',
          'pending': 'В ожидании',
          'confirmed': 'Подтверждено',
          'rejected': 'Отклонено',
          'confirm': 'Подтвердить',
          'reject': 'Отклонить',
          'notificationStatusUpdated': 'Статус уведомления обновлен',
          'updateProfile': 'Обновить профиль',
          'profileUpdated': 'Профиль обновлен',
          'showDetails': 'Показать детали',
          'transactionRejected': 'Транзакция отклонена',
          'showExpenses': 'Показать расходы',
          'showIncomes': 'Показать доходы',
          'acceptAction': 'Действие принять',
          'accept': 'Принять',
          'transaction': 'Транзакция',
          'notifications': 'Уведомления',
          'isExpense': 'Это расход?',
          'notificationStatus': 'Статус уведомления',
          'notificationBody': 'Текст уведомления',
          'close': 'Закрыть',
          'enterValidPhone': 'Введите действительный номер телефона',
          'cannotInviteSelf': 'Нельзя пригласить самого себя',
          'familyMemberInvited': 'Член семьи приглашен',
          'transactionDeleted': 'Транзакция удалена',
          'transactionUpdated': 'Транзакция обновлена',
          'transactionInvolvingYou': 'Транзакция с вашим участием',
          'acceptToSync': 'Принять для синхронизации',
          'familyMembers': 'Члены семьи',
          'changedBy': 'Изменил(а)',
          'inviteFamilyMember': 'Пригласить члена семьи',
          'invite': 'Пригласить',
          'noFamilyMembers': 'Нет членов семьи',
          'invitations': 'Приглашения',
          'noInvitations': 'Нет приглашений',
          'invitationFrom': 'Приглашение от',
          // New strings for HomePage
          'welcomeDriver': 'Добро пожаловать, Водитель!', // NEW
          'driverDetails': 'Ваши данные:', // NEW
          'viewAvailableRides': 'Посмотреть доступные поездки', // NEW
          'viewYourShipments': 'Посмотреть Ваши отправления', // NEW
          'goOnline': 'Выйти в сеть', // NEW
          'driverUtilities': 'Возможности для водителя:', // NEW
          'welcomeClient': 'Добро пожаловать, Клиент!', // NEW
          'clientDetails': 'Ваши данные:', // NEW
          'bookARide': 'Заказать поездку', // NEW
          'viewYourRides': 'Посмотреть Ваши поездки', // NEW
          'trackShipment': 'Отследить отправление', // NEW
          'clientUtilities': 'Возможности для клиента:', // NEW
          'welcomeGuest': 'Добро пожаловать, Гость!', // NEW
          'guestUtilities': 'Возможности для гостя:', // NEW
          'signUpNow': 'Зарегистрироваться сейчас', // NEW
          'loginNow': 'Войти сейчас', // NEW
          'learnMore': 'Узнать больше', // NEW
          'featureComingSoon': 'Функция скоро появится!', // NEW
          // NEW strings for Add Ride & My Rides
          'addRide': 'Добавить поездку',
          'myRides': 'Мои поездки',
          'selectDateTime': 'Пожалуйста, выберите дату и время',
          'rideAddedSuccessfully': 'Поездка успешно добавлена!',
          'rideDetails': 'Детали поездки',
          'selectDate': 'Выбрать дату',
          'selectTime': 'Выбрать время',
          'fromWhere': 'Откуда',
          'toWhere': 'Куда',
          'price': 'Цена',
          'neededPassengers': 'Необходимое количество пассажиров',
          'additionalPhoneNumber': 'Дополнительный номер телефона',
          'deliversObjects': 'Доставляет объекты?',
          'isDailyRide': 'Ежедневная поездка?',
          'addRideButton': 'Добавить поездку',
          'enterFromLocation': 'Пожалуйста, введите место отправления',
          'enterToLocation': 'Пожалуйста, введите место назначения',
          'enterPrice': 'Пожалуйста, введите цену',
          'enterValidPrice': 'Пожалуйста, введите действительное число',
          'enterPassengerCount': 'Пожалуйста, введите количество пассажиров',
          'enterValidNumber': 'Пожалуйста, введите действительное число',
          'noRidesFound': 'Поездок не найдено.',
          'rideStatusUpdated': 'Статус поездки обновлен!',
          'activeStatus': 'Активно',
          'frozenStatus': 'Заморожено',
          'freezeButton': 'Заморозить',
          'activateButton': 'Активировать',
          'confirmDelete': 'Подтвердить удаление',
          'confirmDeleteRide': 'Вы уверены, что хотите удалить эту поездку?',
          'delete': 'Удалить',
          'rideDeletedSuccessfully': 'Поездка успешно удалена!',
          // NEW strings for Book Ride Screen
          'getRideButton': 'Получить поездку',
          'sendOffer': 'Отправить предложение',
          'requestedPassengers': 'Запрошенное количество пассажиров',
          'isShipmentRequest': 'Запрос на отправку?',
          'yourComment': 'Ваш комментарий (необязательно)',
          'offerSentSuccessfully': 'Предложение отправлено успешно!',
          'failedToSendOffer': 'Не удалось отправить предложение',
          'noActiveRides': 'Активных поездок не найдено.',
          'browseRides': 'Просмотреть поездки',
          'cancelRideButton': 'Отменить поездку', // NEW
          'offerCancelledSuccessfully': 'Предложение успешно отменено!', // NEW
          'failedToCancelOffer': 'Не удалось отменить предложение', // NEW
          'takeOverLocation': 'Место получения (необязательно)', // NEW
          // NEW strings for Notifications Screen (Driver Offers)
          'rideOffers': 'Предложения по поездкам', // NEW
          'generalNotifications': 'Общие уведомления', // NEW
          'newRideOffer': 'Новое предложение по поездке!', // NEW
          'fromClient': 'От клиента', // NEW
          'offeredPrice': 'Предложенная цена', // NEW
          'sentAt': 'Отправлено в', // NEW
          'acceptOffer': 'Принять предложение', // NEW
          'rejectOffer': 'Отклонить предложение', // NEW
          'addCommentOptional': 'Добавить комментарий (необязательно):', // NEW
          'offerStatusUpdated': 'Статус предложения обновлен!', // NEW
          'errorUpdatingOffer': 'Ошибка при обновлении предложения', // NEW
          'noPendingOffers': 'Нет ожидающих предложений по поездкам.', // NEW
          'clientComment': 'Комментарий клиента', // NEW
          // NEW strings for My Orders Screen
          'myOrders': 'Мои заказы', // NEW
          'clientOffersTitle': 'Ваши предложения поездок', // NEW
          'noClientOffers': 'Вы еще не отправляли предложения поездок.', // NEW
          'driverAcceptedOffersTitle': 'Ваши принятые заказы клиентов', // NEW
          'noDriverAcceptedOffers':
              'У вас нет принятых заказов клиентов.', // NEW
          'offerFor': 'Предложение для', // NEW
          'pendingStatus': 'Ожидает', // NEW
          'acceptedStatus': 'Принято', // NEW
          'rejectedStatus': 'Отклонено', // NEW
          'cancelledStatus': 'Отменено', // NEW
          'unknownStatus': 'Неизвестно', // NEW
          'driverId': 'ID водителя', // NEW
          'driverPhoneNumber': 'Телефон водителя', // NEW
          'respondedAt': 'Время ответа', // NEW
          'removeOrder': 'Удалить заказ', // NEW
          'confirmDeleteOffer':
              'Вы уверены, что хотите удалить это предложение?', // NEW
          'offerRemovedSuccessfully': 'Предложение успешно удалено!', // NEW
          'failedToRemoveOffer': 'Не удалось удалить предложение', // NEW
          'driverUsername': 'Имя водителя', // NEW
          'driverInfo': 'Информация о водителе', // NEW
          'notAvailable': 'Недоступно', // NEW
          'loadingRideDetails': 'Загрузка деталей поездки...', // NEW
          'notDailyRide': 'Не ежедневная поездка', // NEW
          'filterFromLocation': 'Фильтр по месту отправления', // NEW
          'filterToLocation': 'Фильтр по месту назначения', // NEW
          'searchDriver': 'Поиск водителя', // NEW
          'selectDateFilter': 'Выбрать фильтр по дате', // NEW
          'clearDateFilter': 'Очистить фильтр по дате', // NEW
          'filterRides': 'Филтрь поездки', // NEW
          'selectLocationOnMap': 'Выбрать местоположение на карте', // NEW
          'changeLocation': 'Изменить местоположение', // NEW
          'selectedLocation': 'Выбранное местоположение', // NEW
          'latitude': 'Широта', // NEW
          'longitude': 'Долгота', // NEW
          'locationAddress': 'Адрес местоположения', // NEW
          'enterCoordinatesManually': 'Введите координаты и адрес для имитации выбора на карте.', // NEW
          'selectTakeOverLocation': 'Выбрать место получения', // NEW
          'clear': 'Очистить', // NEW
          'select': 'Выбрать', // NEW
          'enterValidLocationData': 'Пожалуйста, введите действительный адрес, широту и долготу.', // NEW
          'locationSelected': 'Местоположение выбрано', // NEW
          'locationCleared': 'Выбор местоположения очищен.', // NEW
          'viewOnMap': 'Посмотреть на карте', // NEW
          'cannotLaunchMap': 'Не удалось запустить карту.', // NEW
          'clearFilter': 'Очистить фильтр',
          'selectTakeOverLocation': 'Выбрать место получения', // NEW
          'mapSelectionInstructions': 'Откройте Google Карты, чтобы найти и скопировать координаты/адрес, затем вставьте сюда:', // NEW
          'mapSelectionInstructionsTitle': 'Как выбрать местоположение:', // NEW
        };
      default: // en
        return {
          'authTitle': 'Login and Registration',
          'loginTab': 'Login',
          'registerTab': 'Register',
          'email': 'Email',
          'password': 'Password',
          'username': 'Username',
          'newPhone': 'New phone number (+998)',
          'phone': 'Phone number',
          'smsCode': 'SMS code',
          'fillAllFields': 'Please fill in all fields',
          'loginButton': 'Login',
          'verifyAndRegisterButton': 'Verify phone and register',
          'verifyCodeButton': 'Verify code and register',
          'loginSuccess': 'Login successful',
          'registerSuccess': 'Registration successful',
          'emailRegisterSuccess': 'Email registration successful',
          'error': 'Error',
          'smsCodeSent': 'SMS code sent',
          'enterSmsCode': 'Enter SMS code',
          'userNotFound': 'User not found',
          'emailLinkError': 'Error linking email',
          'updateButton': 'Update information',
          'profileTitle': 'Profile',
          'userDataTab': 'User Data',
          'editDataTab': 'Edit Data',
          'logout': 'Logout',
          'deleteAccount': 'Delete Account',
          'accountDeleted': 'Account deleted',
          'notSet': 'Not set',
          'enterNewEmail': 'Enter new email',
          'enterNewPassword': 'Enter new password',
          'enterNewPhone': 'Enter new phone number',
          'enterUsername': 'Enter username',
          'emailUpdated': 'Email updated',
          'passwordUpdated': 'Password updated',
          'phoneUpdated': 'Phone number updated',
          'usernameUpdated': 'Username updated',
          'updateError': 'Update error',
          'phoneVerificationError': 'Phone verification error',
          'emailNotVerified': 'Email must be verified to change phone number',
          'pickPhoto': 'Pick Profile Photo',
          'uploadPhoto': 'Upload Profile Photo',
          'photoUpdated': 'Profile photo updated',
          'adminSection': 'Admin Panel',
          'userBlocked': 'User blocked',
          'userUnblocked': 'User unblocked',
          'selectDataToEdit': 'Select data to edit',
          'updateEmailButton': 'Update Email',
          'updatePasswordButton': 'Update Password',
          'updatePhoneButton': 'Update Phone Number',
          'updateUsernameButton': 'Update Username',
          'verifyNewPhoneButton': 'Verify New Phone',
          'profilePhoto': 'Profile Photo',
          'forgotPassword': 'Forgot Password?',
          'resetPassword': 'Reset Password',
          'enterEmail': 'Enter email',
          'cancel': 'Cancel',
          'sendResetLink': 'Send Reset Link',
          'resetEmailSent': 'Password reset email sent',
          'resetEmailError': 'Reset email error',
          'continueWithoutLogin': 'Continue without login',
          'homeTitle': 'Home',
          'settings': 'Settings',
          'language': 'Language',
          'expensesAndIncome': 'Expenses and Income',
          'transactionTitle': 'Expenses/Income',
          'transactionPlaceholder': 'Expenses and income management page',
          'usePhoneLogin': 'Use phone number to log in',
          'loginRequired': 'Please log in to access this feature',
          'loading': 'Loading...',
          'budgetOverview': 'Budget Overview',
          'transactionHistory': 'Transaction History',
          'enterTransaction': 'Enter Transaction',
          'selectPeriod': 'Select Period',
          'totalIncome': 'Total Income',
          'totalExpenses': 'Total Expenses',
          'balance': 'Balance',
          'amount': 'Amount',
          'transactionType': 'Transaction Type',
          'saveTransaction': 'Save Transaction',
          'manageTypes': 'Manage Transaction Types',
          'newType': 'New Transaction Type',
          'addType': 'Add Type',
          'expense': 'Expense',
          'income': 'Income',
          'transactionSaved': 'Transaction Saved',
          'notificationsTitle': 'Notifications',
          'newTransaction': 'New Transaction',
          'newTransactionBody': 'You have a new loan transaction to review.',
          'confirmTransaction': 'Confirm Transaction',
          'cancelTransaction': 'Cancel Transaction',
          'transactionDetails': 'Transaction Details',
          'transactionConfirmed': 'Transaction Confirmed',
          'transactionCancelled': 'Transaction Cancelled',
          'notificationSent': 'Notification Sent',
          'status': 'Status',
          'type': 'Type',
          'category': 'Category',
          'date': 'Date',
          'recipientNotFound': 'Recipient not found',
          'multipleRecipients': 'Multiple users found for this phone number',
          'details': 'Details',
          'sendNotification': 'Send notification?',
          'yes': 'Yes',
          'no': 'No',
          'noData': "No data",
          'bank_loan': "Bank loan",
          'loan_to_friends': "Pay off debt",
          'loan_from_friends': "Get debt",
          'salary': "Salary",
          'selectRole': 'Select Role', // NEW
          'client': 'Client', // NEW
          'driver': 'Driver', // NEW
          'carNumber': 'Car Number', // NEW
          'carType': 'Car Type', // NEW
          'invitationCanceled': 'Invitation canceled',
          'viewPrimaryTransactions': 'View Primary Transactions',
          'noNotifications': 'No notifications',
          'checkFirestore': 'Check Firestore',
          'newEmail': 'New Email',
          'newPassword': 'New Password',
          'pending': 'Pending',
          'confirmed': 'Confirmed',
          'rejected': 'Rejected',
          'confirm': 'Confirm',
          'reject': 'Reject',
          'notificationStatusUpdated': 'Notification status updated',
          'updateProfile': 'Update Profile',
          'profileUpdated': 'Profile updated',
          'showDetails': 'Show Details',
          'transactionRejected': 'Transaction Rejected',
          'showExpenses': 'Show Expenses',
          'showIncomes': 'Show Incomes',
          'acceptAction': 'Accept Action',
          'accept': 'Accept',
          'transaction': 'Transaction',
          'notifications': 'Notifications',
          'isExpense': 'Is Expense?',
          'notificationStatus': 'Notification Status',
          'notificationBody': 'Notification Body',
          'close': 'Close',
          'enterValidPhone': 'Enter valid phone number',
          'cannotInviteSelf': 'Cannot invite self',
          'familyMemberInvited': 'Family member invited',
          'transactionDeleted': 'Transaction deleted',
          'transactionUpdated': 'Transaction updated',
          'transactionInvolvingYou': 'Transaction involving you',
          'acceptToSync': 'Accept to sync',
          'familyMembers': 'Family Members',
          'changedBy': 'Changed by',
          'inviteFamilyMember': 'Invite Family Member',
          'invite': 'Invite',
          'noFamilyMembers': 'No family members',
          'invitations': 'Invitations',
          'noInvitations': 'No invitations',
          'invitationFrom': 'Invitation from',
          // New strings for HomePage
          'welcomeDriver': 'Welcome, Driver!', // NEW
          'driverDetails': 'Your Details:', // NEW
          'viewAvailableRides': 'View Available Rides', // NEW
          'viewYourShipments': 'View Your Shipments', // NEW
          'goOnline': 'Go Online', // NEW
          'driverUtilities': 'Driver Utilities:', // NEW
          'welcomeClient': 'Welcome, Client!', // NEW
          'clientDetails': 'Your Details:', // NEW
          'bookARide': 'Book a Ride', // NEW
          'viewYourRides': 'View Your Rides', // NEW
          'trackShipment': 'Track Shipment', // NEW
          'clientUtilities': 'Client Utilities:', // NEW
          'welcomeGuest': 'Welcome, Guest!', // NEW
          'guestUtilities': 'Guest Utilities:', // NEW
          'signUpNow': 'Sign Up Now', // NEW
          'loginNow': 'Login Now', // NEW
          'learnMore': 'Learn More', // NEW
          'featureComingSoon': 'Feature coming soon!', // NEW
          // NEW strings for Add Ride & My Rides
          'addRide': 'Add Ride',
          'myRides': 'My Rides',
          'selectDateTime': 'Please select date and time',
          'rideAddedSuccessfully': 'Ride added successfully!',
          'rideDetails': 'Ride Details',
          'selectDate': 'Select Date',
          'selectTime': 'Select Time',
          'fromWhere': 'From Where',
          'toWhere': 'To Where',
          'price': 'Price',
          'neededPassengers': 'Needed Passengers Count',
          'additionalPhoneNumber': 'Additional Phone Number',
          'deliversObjects': 'Delivers Objects?',
          'isDailyRide': 'Daily Ride?',
          'addRideButton': 'Add Ride',
          'enterFromLocation': 'Please enter origin location',
          'enterToLocation': 'Please enter destination location',
          'enterPrice': 'Please enter price',
          'enterValidPrice': 'Please enter a valid number',
          'enterPassengerCount': 'Please enter passenger count',
          'enterValidNumber': 'Please enter a valid number',
          'noRidesFound': 'No rides found.',
          'rideStatusUpdated': 'Ride status updated!',
          'activeStatus': 'Active',
          'frozenStatus': 'Frozen',
          'freezeButton': 'Freeze',
          'activateButton': 'Activate',
          'confirmDelete': 'Confirm Delete',
          'confirmDeleteRide': 'Are you sure you want to delete this ride?',
          'delete': 'Delete',
          'rideDeletedSuccessfully': 'Ride deleted successfully!',
          // NEW strings for Book Ride Screen
          'getRideButton': 'Get Ride',
          'sendOffer': 'Send Offer',
          'requestedPassengers': 'Requested Passengers',
          'isShipmentRequest': 'Is Shipment Request?',
          'yourComment': 'Your Comment (Optional)',
          'offerSentSuccessfully': 'Offer sent successfully!',
          'failedToSendOffer': 'Failed to send offer',
          'noActiveRides': 'No active rides found.',
          'browseRides': 'Browse Rides',
          'cancelRideButton': 'Cancel Ride', // NEW
          'offerCancelledSuccessfully': 'Offer cancelled successfully!', // NEW
          'failedToCancelOffer': 'Failed to cancel offer', // NEW
          'takeOverLocation': 'Take Over Location (Optional)', // NEW
          // NEW strings for Notifications Screen (Driver Offers)
          'rideOffers': 'Ride Offers', // NEW
          'generalNotifications': 'General Notifications', // NEW
          'newRideOffer': 'New Ride Offer!', // NEW
          'fromClient': 'From Client', // NEW
          'offeredPrice': 'Offered Price', // NEW
          'sentAt': 'Sent At', // NEW
          'acceptOffer': 'Accept Offer', // NEW
          'rejectOffer': 'Reject Offer', // NEW
          'addCommentOptional': 'Add a comment (optional):', // NEW
          'offerStatusUpdated': 'Offer status updated!', // NEW
          'errorUpdatingOffer': 'Error updating offer', // NEW
          'noPendingOffers': 'No pending ride offers.', // NEW
          'clientComment': 'Client Comment', // NEW
          // NEW strings for My Orders Screen
          'myOrders': 'My Orders', // NEW
          'clientOffersTitle': 'Your Ride Offers', // NEW
          'noClientOffers': 'You have not sent any ride offers yet.', // NEW
          'driverAcceptedOffersTitle': 'Your Accepted Client Offers', // NEW
          'noDriverAcceptedOffers':
              'You have no accepted client offers.', // NEW
          'offerFor': 'Offer for', // NEW
          'pendingStatus': 'Pending', // NEW
          'acceptedStatus': 'Accepted', // NEW
          'rejectedStatus': 'Rejected', // NEW
          'cancelledStatus': 'Cancelled', // NEW
          'unknownStatus': 'Unknown', // NEW
          'driverId': 'Driver ID', // NEW
          'driverPhoneNumber': 'Driver Phone', // NEW
          'respondedAt': 'Responded At', // NEW
          'removeOrder': 'Remove Order', // NEW
          'confirmDeleteOffer':
              'Are you sure you want to remove this offer?', // NEW
          'offerRemovedSuccessfully': 'Offer removed successfully!', // NEW
          'failedToRemoveOffer': 'Failed to remove offer', // NEW
          'driverUsername': 'Driver Username', // NEW
          'driverInfo': 'Driver Info', // NEW
          'notAvailable': 'Not Available', // NEW
          'loadingRideDetails': 'Loading ride details...', // NEW
          'notDailyRide': 'Not Daily Ride', // NEW
          'filterFromLocation': 'Filter From Location', // NEW
          'filterToLocation': 'Filter To Location', // NEW
          'searchDriver': 'Search Driver (Username or Phone)', // NEW
          'selectDateFilter': 'Select Date Filter', // NEW
          'clearDateFilter': 'Clear Date Filter', // NEW
          'filterRides': 'Filter rides', // NEW
          'selectLocationOnMap': 'Select Location on Map', // NEW
          'changeLocation': 'Change Location', // NEW
          'selectedLocation': 'Selected Location', // NEW
          'latitude': 'Latitude', // NEW
          'longitude': 'Longitude', // NEW
          'locationAddress': 'Location Address', // NEW
          'enterCoordinatesManually': 'Enter coordinates and address to simulate map selection.', // NEW
          'selectTakeOverLocation': 'Select Take Over Location', // NEW
          'clear': 'Clear', // NEW
          'select': 'Select', // NEW
          'enterValidLocationData': 'Please enter a valid address, latitude, and longitude.', // NEW
          'locationSelected': 'Location selected', // NEW
          'locationCleared': 'Location selection cleared.', // NEW
          'viewOnMap': 'View on Map', // NEW
          'cannotLaunchMap': 'Could not launch map.', // NEW
          'clearFilter': 'Clear Filter',
          'selectTakeOverLocation': 'Select Take Over Location', // NEW
          'mapSelectionInstructions': 'Open Google Maps to find and copy coordinates/address, then paste here:', // NEW
          'mapSelectionInstructionsTitle': 'How to Select Location:', // NEW
          'mapSelectionInstructionsDetail': '1. Tap "Open Google Maps" below.\n2. In Google Maps, find your desired location.\n3. Tap and hold on the map to drop a pin. This will show coordinates (latitude, longitude) and an address.\n4. Copy these values and paste them into the fields below.\n5. Tap "Select Location" to confirm.', // NEW
        };
    }
  }

  // Barcha yangi stringlar uchun getterlar qo'shildi
  String? get authTitle => _getLocalizedValues()['authTitle'];
  String? get loginTab => _getLocalizedValues()['loginTab'];
  String? get registerTab => _getLocalizedValues()['registerTab'];
  String? get email => _getLocalizedValues()['email'];
  String? get password => _getLocalizedValues()['password'];
  String? get username => _getLocalizedValues()['username'];
  String? get newPhone => _getLocalizedValues()['newPhone'];
  String? get phone => _getLocalizedValues()['phone'];
  String? get smsCode => _getLocalizedValues()['smsCode'];
  String? get fillAllFields => _getLocalizedValues()['fillAllFields'];
  String? get loginButton => _getLocalizedValues()['loginButton'];
  String? get verifyAndRegisterButton =>
      _getLocalizedValues()['verifyAndRegisterButton'];
  String? get verifyCodeButton => _getLocalizedValues()['verifyCodeButton'];
  String? get loginSuccess => _getLocalizedValues()['loginSuccess'];
  String? get registerSuccess => _getLocalizedValues()['registerSuccess'];
  String? get emailRegisterSuccess =>
      _getLocalizedValues()['emailRegisterSuccess'];
  String? get error => _getLocalizedValues()['error'];
  String? get smsCodeSent => _getLocalizedValues()['smsCodeSent'];
  String? get enterSmsCode => _getLocalizedValues()['enterSmsCode'];
  String? get userNotFound => _getLocalizedValues()['userNotFound'];
  String? get emailLinkError => _getLocalizedValues()['emailLinkError'];
  String? get updateButton => _getLocalizedValues()['updateButton'];
  String? get profileTitle => _getLocalizedValues()['profileTitle'];
  String? get userDataTab => _getLocalizedValues()['userDataTab'];
  String? get editDataTab => _getLocalizedValues()['editDataTab'];
  String? get logout => _getLocalizedValues()['logout'];
  String? get deleteAccount => _getLocalizedValues()['deleteAccount'];
  String? get accountDeleted => _getLocalizedValues()['accountDeleted'];
  String? get notSet => _getLocalizedValues()['notSet'];
  String? get enterNewEmail => _getLocalizedValues()['enterNewEmail'];
  String? get enterNewPassword => _getLocalizedValues()['enterNewPassword'];
  String? get enterNewPhone => _getLocalizedValues()['enterNewPhone'];
  String? get enterUsername => _getLocalizedValues()['enterUsername'];
  String? get emailUpdated => _getLocalizedValues()['emailUpdated'];
  String? get passwordUpdated => _getLocalizedValues()['passwordUpdated'];
  String? get phoneUpdated => _getLocalizedValues()['phoneUpdated'];
  String? get usernameUpdated => _getLocalizedValues()['usernameUpdated'];
  String? get updateError => _getLocalizedValues()['updateError'];
  String? get phoneVerificationError =>
      _getLocalizedValues()['phoneVerificationError'];
  String? get emailNotVerified => _getLocalizedValues()['emailNotVerified'];
  String? get pickPhoto => _getLocalizedValues()['pickPhoto'];
  String? get uploadPhoto => _getLocalizedValues()['uploadPhoto'];
  String? get photoUpdated => _getLocalizedValues()['photoUpdated'];
  String? get adminSection => _getLocalizedValues()['adminSection'];
  String? get userBlocked => _getLocalizedValues()['userBlocked'];
  String? get userUnblocked => _getLocalizedValues()['userUnblocked'];
  String? get selectDataToEdit => _getLocalizedValues()['selectDataToEdit'];
  String? get updateEmailButton => _getLocalizedValues()['updateEmailButton'];
  String? get updatePasswordButton =>
      _getLocalizedValues()['updatePasswordButton'];
  String? get updatePhoneButton => _getLocalizedValues()['updatePhoneButton'];
  String? get updateUsernameButton =>
      _getLocalizedValues()['updateUsernameButton'];
  String? get verifyNewPhoneButton =>
      _getLocalizedValues()['verifyNewPhoneButton'];
  String? get profilePhoto => _getLocalizedValues()['profilePhoto'];
  String? get forgotPassword => _getLocalizedValues()['forgotPassword'];
  String? get resetPassword => _getLocalizedValues()['resetPassword'];
  String? get enterEmail => _getLocalizedValues()['enterEmail'];
  String? get cancel => _getLocalizedValues()['cancel'];
  String? get sendResetLink => _getLocalizedValues()['sendResetLink'];
  String? get resetEmailSent => _getLocalizedValues()['resetEmailSent'];
  String? get resetEmailError => _getLocalizedValues()['resetEmailError'];
  String? get continueWithoutLogin =>
      _getLocalizedValues()['continueWithoutLogin'];
  String? get homeTitle => _getLocalizedValues()['homeTitle'];
  String? get settings => _getLocalizedValues()['settings'];
  String? get language => _getLocalizedValues()['language'];
  String? get expensesAndIncome => _getLocalizedValues()['expensesAndIncome'];
  String? get transactionTitle => _getLocalizedValues()['transactionTitle'];
  String? get transactionPlaceholder =>
      _getLocalizedValues()['transactionPlaceholder'];
  String? get usePhoneLogin => _getLocalizedValues()['usePhoneLogin'];
  String? get loginRequired => _getLocalizedValues()['loginRequired'];
  String? get loading => _getLocalizedValues()['loading'];
  String? get budgetOverview => _getLocalizedValues()['budgetOverview'];
  String? get transactionHistory => _getLocalizedValues()['transactionHistory'];
  String? get enterTransaction => _getLocalizedValues()['enterTransaction'];
  String? get selectPeriod => _getLocalizedValues()['selectPeriod'];
  String? get totalIncome => _getLocalizedValues()['totalIncome'];
  String? get totalExpenses => _getLocalizedValues()['totalExpenses'];
  String? get balance => _getLocalizedValues()['balance'];
  String? get amount => _getLocalizedValues()['amount'];
  String? get transactionType => _getLocalizedValues()['transactionType'];
  String? get saveTransaction => _getLocalizedValues()['saveTransaction'];
  String? get manageTypes => _getLocalizedValues()['manageTypes'];
  String? get newType => _getLocalizedValues()['newType'];
  String? get addType => _getLocalizedValues()['addType'];
  String? get expense => _getLocalizedValues()['expense'];
  String? get income => _getLocalizedValues()['income'];
  String? get transactionSaved => _getLocalizedValues()['transactionSaved'];
  String? get notificationsTitle => _getLocalizedValues()['notificationsTitle'];
  String? get newTransaction => _getLocalizedValues()['newTransaction'];
  String? get newTransactionBody => _getLocalizedValues()['newTransactionBody'];
  String? get confirmTransaction => _getLocalizedValues()['confirmTransaction'];
  String? get cancelTransaction => _getLocalizedValues()['cancelTransaction'];
  String? get transactionDetails => _getLocalizedValues()['transactionDetails'];
  String? get transactionConfirmed =>
      _getLocalizedValues()['transactionConfirmed'];
  String? get transactionCancelled =>
      _getLocalizedValues()['transactionCancelled'];
  String? get notificationSent => _getLocalizedValues()['notificationSent'];
  String? get status => _getLocalizedValues()['status'];
  String? get type => _getLocalizedValues()['type'];
  String? get category => _getLocalizedValues()['category'];
  String? get noNotifications => _getLocalizedValues()['noNotifications'];
  String? get checkFirestore => _getLocalizedValues()['checkFirestore'];
  String? get date => _getLocalizedValues()['date'];
  String? get newEmail => _getLocalizedValues()['newEmail'];
  String? get newPassword => _getLocalizedValues()['newPassword'];
  String? get recipientNotFound => _getLocalizedValues()['recipientNotFound'];
  String? get multipleRecipients => _getLocalizedValues()['multipleRecipients'];
  String? get pending => _getLocalizedValues()['pending'];
  String? get confirmed => _getLocalizedValues()['confirmed'];
  String? get rejected => _getLocalizedValues()['rejected'];
  String? get confirm => _getLocalizedValues()['confirm'];
  String? get reject => _getLocalizedValues()['reject'];
  String? get notificationStatusUpdated =>
      _getLocalizedValues()['notificationStatusUpdated'];
  String? get updateProfile => _getLocalizedValues()['updateProfile'];
  String? get profileUpdated => _getLocalizedValues()['profileUpdated'];
  String? get showDetails => _getLocalizedValues()['showDetails'];
  String? get transactionRejected =>
      _getLocalizedValues()['transactionRejected'];
  String? get sendNotification => _getLocalizedValues()['sendNotification'];
  String? get details => _getLocalizedValues()['details'];
  String? get yes => _getLocalizedValues()['yes'];
  String? get no => _getLocalizedValues()['no'];
  String? get noData => _getLocalizedValues()['noData'];
  String? get showExpenses => _getLocalizedValues()['showExpenses'];
  String? get showIncomes => _getLocalizedValues()['showIncomes'];
  String? get acceptAction => _getLocalizedValues()['acceptAction'];
  String? get accept => _getLocalizedValues()['accept'];
  String? get transaction => _getLocalizedValues()['transaction'];
  String? get notifications => _getLocalizedValues()['notifications'];
  String? get isExpense => _getLocalizedValues()['isExpense'];
  String? get notificationStatus => _getLocalizedValues()['notificationStatus'];
  String? get notificationBody => _getLocalizedValues()['notificationBody'];
  String? get close => _getLocalizedValues()['close'];
  String? get enterValidPhone => _getLocalizedValues()['enterValidPhone'];
  String? get cannotInviteSelf => _getLocalizedValues()['cannotInviteSelf'];
  String? get familyMemberInvited =>
      _getLocalizedValues()['familyMemberInvited'];
  String? get transactionDeleted => _getLocalizedValues()['transactionDeleted'];
  String? get transactionUpdated => _getLocalizedValues()['transactionUpdated'];
  String? get transactionInvolvingYou =>
      _getLocalizedValues()['transactionInvolvingYou'];
  String? get acceptToSync => _getLocalizedValues()['acceptToSync'];
  String? get familyMembers => _getLocalizedValues()['familyMembers'];
  String? get changedBy => _getLocalizedValues()['changedBy'];
  String? get inviteFamilyMember => _getLocalizedValues()['inviteFamilyMember'];
  String? get invite => _getLocalizedValues()['invite'];
  String? get noFamilyMembers => _getLocalizedValues()['noFamilyMembers'];
  String? get invitations => _getLocalizedValues()['invitations'];
  String? get noInvitations => _getLocalizedValues()['noInvitations'];
  String? get invitationFrom => _getLocalizedValues()['invitationFrom'];
  String? get selectRole => _getLocalizedValues()['selectRole']; // NEW
  String? get client => _getLocalizedValues()['client']; // NEW
  String? get driver => _getLocalizedValues()['driver']; // NEW
  String? get carNumber => _getLocalizedValues()['carNumber']; // NEW
  String? get carType => _getLocalizedValues()['carType']; // NEW
  String? get invitationCanceled => _getLocalizedValues()['invitationCanceled'];
  String? get viewPrimaryTransactions =>
      _getLocalizedValues()['viewPrimaryTransactions'];
  // Yangi HomePage stringlari uchun getterlar
  String? get welcomeDriver => _getLocalizedValues()['welcomeDriver'];
  String? get driverDetails => _getLocalizedValues()['driverDetails'];
  String? get viewAvailableRides => _getLocalizedValues()['viewAvailableRides'];
  String? get viewYourShipments => _getLocalizedValues()['viewYourShipments'];
  String? get goOnline => _getLocalizedValues()['goOnline'];
  String? get driverUtilities => _getLocalizedValues()['driverUtilities'];
  String? get welcomeClient => _getLocalizedValues()['welcomeClient'];
  String? get clientDetails => _getLocalizedValues()['clientDetails'];
  String? get bookARide => _getLocalizedValues()['bookARide'];
  String? get viewYourRides => _getLocalizedValues()['viewYourRides'];
  String? get trackShipment => _getLocalizedValues()['trackShipment'];
  String? get clientUtilities => _getLocalizedValues()['clientUtilities'];
  String? get welcomeGuest => _getLocalizedValues()['welcomeGuest'];
  String? get guestUtilities => _getLocalizedValues()['guestUtilities'];
  String? get signUpNow => _getLocalizedValues()['signUpNow'];
  String? get loginNow => _getLocalizedValues()['loginNow'];
  String? get learnMore => _getLocalizedValues()['learnMore'];
  String? get featureComingSoon => _getLocalizedValues()['featureComingSoon'];

  // NEW strings for Add Ride & My Rides
  String? get addRide => _getLocalizedValues()['addRide'];
  String? get myRides => _getLocalizedValues()['myRides'];
  String? get selectDateTime => _getLocalizedValues()['selectDateTime'];
  String? get rideAddedSuccessfully =>
      _getLocalizedValues()['rideAddedSuccessfully'];
  String? get rideDetails => _getLocalizedValues()['rideDetails'];
  String? get selectDate => _getLocalizedValues()['selectDate'];
  String? get selectTime => _getLocalizedValues()['selectTime'];
  String? get fromWhere => _getLocalizedValues()['fromWhere'];
  String? get toWhere => _getLocalizedValues()['toWhere'];
  String? get price => _getLocalizedValues()['price'];
  String? get neededPassengers => _getLocalizedValues()['neededPassengers'];
  String? get additionalPhoneNumber =>
      _getLocalizedValues()['additionalPhoneNumber'];
  String? get deliversObjects => _getLocalizedValues()['deliversObjects'];
  String? get isDailyRide => _getLocalizedValues()['isDailyRide'];
  String? get addRideButton => _getLocalizedValues()['addRideButton'];
  String? get enterFromLocation => _getLocalizedValues()['enterFromLocation'];
  String? get enterToLocation => _getLocalizedValues()['enterToLocation'];
  String? get enterPrice => _getLocalizedValues()['enterPrice'];
  String? get enterValidPrice => _getLocalizedValues()['enterValidPrice'];
  String? get enterPassengerCount =>
      _getLocalizedValues()['enterPassengerCount'];
  String? get enterValidNumber => _getLocalizedValues()['enterValidNumber'];
  String? get noRidesFound => _getLocalizedValues()['noRidesFound'];
  String? get rideStatusUpdated => _getLocalizedValues()['rideStatusUpdated'];
  String? get activeStatus => _getLocalizedValues()['activeStatus'];
  String? get frozenStatus => _getLocalizedValues()['frozenStatus'];
  String? get freezeButton => _getLocalizedValues()['freezeButton'];
  String? get activateButton => _getLocalizedValues()['activateButton'];
  String? get confirmDelete => _getLocalizedValues()['confirmDelete'];
  String? get dateTime => _getLocalizedValues()['dateTime'];
  String? get confirmDeleteRide => _getLocalizedValues()['confirmDeleteRide'];
  String? get delete => _getLocalizedValues()['delete'];
  String? get rideDeletedSuccessfully =>
      _getLocalizedValues()['rideDeletedSuccessfully'];
  // NEW strings for Book Ride Screen
  String? get getRideButton => _getLocalizedValues()['getRideButton'];
  String? get sendOffer => _getLocalizedValues()['sendOffer'];
  String? get requestedPassengers =>
      _getLocalizedValues()['requestedPassengers'];
  String? get isShipmentRequest => _getLocalizedValues()['isShipmentRequest'];
  String? get yourComment => _getLocalizedValues()['yourComment'];
  String? get offerSentSuccessfully =>
      _getLocalizedValues()['offerSentSuccessfully'];
  String? get failedToSendOffer => _getLocalizedValues()['failedToSendOffer'];
  String? get noActiveRides => _getLocalizedValues()['noActiveRides'];
  String? get browseRides => _getLocalizedValues()['browseRides'];
  String? get cancelRideButton =>
      _getLocalizedValues()['cancelRideButton']; // NEW
  String? get offerCancelledSuccessfully =>
      _getLocalizedValues()['offerCancelledSuccessfully']; // NEW
  String? get failedToCancelOffer =>
      _getLocalizedValues()['failedToCancelOffer']; // NEW
  String? get takeOverLocation =>
      _getLocalizedValues()['takeOverLocation']; // NEW
  // NEW strings for Notifications Screen (Driver Offers)
  String? get rideOffers => _getLocalizedValues()['rideOffers']; // NEW
  String? get generalNotifications =>
      _getLocalizedValues()['generalNotifications']; // NEW
  String? get newRideOffer => _getLocalizedValues()['newRideOffer']; // NEW
  String? get fromClient => _getLocalizedValues()['fromClient']; // NEW
  String? get offeredPrice => _getLocalizedValues()['offeredPrice']; // NEW
  String? get sentAt => _getLocalizedValues()['sentAt']; // NEW
  String? get acceptOffer => _getLocalizedValues()['acceptOffer']; // NEW
  String? get rejectOffer => _getLocalizedValues()['rejectOffer']; // NEW
  String? get addCommentOptional =>
      _getLocalizedValues()['addCommentOptional']; // NEW
  String? get offerStatusUpdated =>
      _getLocalizedValues()['offerStatusUpdated']; // NEW
  String? get errorUpdatingOffer =>
      _getLocalizedValues()['errorUpdatingOffer']; // NEW
  String? get noPendingOffers =>
      _getLocalizedValues()['noPendingOffers']; // NEW
  String? get clientComment => _getLocalizedValues()['clientComment']; // NEW
  // NEW strings for My Orders Screen
  String? get myOrders => _getLocalizedValues()['myOrders']; // NEW
  String? get clientOffersTitle =>
      _getLocalizedValues()['clientOffersTitle']; // NEW
  String? get noClientOffers => _getLocalizedValues()['noClientOffers']; // NEW
  String? get driverAcceptedOffersTitle =>
      _getLocalizedValues()['driverAcceptedOffersTitle']; // NEW
  String? get noDriverAcceptedOffers =>
      _getLocalizedValues()['noDriverAcceptedOffers']; // NEW
  String? get offerFor => _getLocalizedValues()['offerFor']; // NEW
  String? get pendingStatus => _getLocalizedValues()['pendingStatus']; // NEW
  String? get acceptedStatus => _getLocalizedValues()['acceptedStatus']; // NEW
  String? get rejectedStatus => _getLocalizedValues()['rejectedStatus']; // NEW
  String? get cancelledStatus =>
      _getLocalizedValues()['cancelledStatus']; // NEW
  String? get unknownStatus => _getLocalizedValues()['unknownStatus']; // NEW
  String? get driverId => _getLocalizedValues()['driverId']; // NEW
  String? get driverPhoneNumber =>
      _getLocalizedValues()['driverPhoneNumber']; // NEW
  String? get respondedAt => _getLocalizedValues()['respondedAt']; // NEW
  String? get clientUsername => _getLocalizedValues()['clientUsername']; // NEW
  String? get clientPhoneNumber =>
      _getLocalizedValues()['clientPhoneNumber']; // NEW
  String? get driverComment => _getLocalizedValues()['driverComment']; // NEW
  String? get removeOrder => _getLocalizedValues()['removeOrder']; // NEW
  String? get confirmDeleteOffer =>
      _getLocalizedValues()['confirmDeleteOffer']; // NEW
  String? get offerRemovedSuccessfully =>
      _getLocalizedValues()['offerRemovedSuccessfully']; // NEW
  String? get failedToRemoveOffer =>
      _getLocalizedValues()['failedToRemoveOffer']; // NEW
  String? get driverUsername => _getLocalizedValues()['driverUsername']; // NEW
  String? get driverInfo => _getLocalizedValues()['driverInfo']; // NEW
  String? get notAvailable => _getLocalizedValues()['notAvailable']; // NEW
  String? get loadingRideDetails =>
      _getLocalizedValues()['loadingRideDetails']; // NEW
  String? get notDailyRide => _getLocalizedValues()['notDailyRide']; // NEW
  String? get filterFromLocation =>
      _getLocalizedValues()['filterFromLocation']; // NEW
  String? get filterToLocation =>
      _getLocalizedValues()['filterToLocation']; // NEW
  String? get searchDriver => _getLocalizedValues()['searchDriver']; // NEW
  String? get selectDateFilter =>
      _getLocalizedValues()['selectDateFilter']; // NEW
  String? get clearDateFilter =>
      _getLocalizedValues()['clearDateFilter']; // NEW
  String? get filterRides => _getLocalizedValues()['filterRides']; // NEW
  String? get selectFromLocation =>
      _getLocalizedValues()['selectFromLocation']; // NEW
  String? get selectToLocation =>
      _getLocalizedValues()['selectToLocation']; // NEW
  String? get selectLocationOnMap => _getLocalizedValues()['selectLocationOnMap']; // NEW
  String? get changeLocation => _getLocalizedValues()['changeLocation']; // NEW
  String? get selectedLocation => _getLocalizedValues()['selectedLocation']; // NEW
  String? get latitude => _getLocalizedValues()['latitude']; // NEW
  String? get longitude => _getLocalizedValues()['longitude']; // NEW
  String? get locationAddress => _getLocalizedValues()['locationAddress']; // NEW
  String? get enterCoordinatesManually => _getLocalizedValues()['enterCoordinatesManually']; // NEW
  String? get selectTakeOverLocation => _getLocalizedValues()['selectTakeOverLocation']; // NEW
  String? get clear => _getLocalizedValues()['clear']; // NEW
  String? get select => _getLocalizedValues()['select']; // NEW
  String? get enterValidLocationData => _getLocalizedValues()['enterValidLocationData']; // NEW
  String? get locationSelected => _getLocalizedValues()['locationSelected']; // NEW
  String? get locationCleared => _getLocalizedValues()['locationCleared']; // NEW
  String? get viewOnMap => _getLocalizedValues()['viewOnMap']; // NEW
  String? get cannotLaunchMap => _getLocalizedValues()['cannotLaunchMap']; // NEW
  String? get mapSelectionInstructions => _getLocalizedValues()['mapSelectionInstructions']; // NEW
  String? get openGoogleMaps => _getLocalizedValues()['openGoogleMaps'];
  String? get clearFilter => _getLocalizedValues()['clearFilter'];
  String? get mapSelectionInstructionsTitle => _getLocalizedValues()['mapSelectionInstructionsTitle'];
  String? get mapSelectionInstructionsDetail => _getLocalizedValues()['mapSelectionInstructionsDetail'];
  String? get manualInput => _getLocalizedValues()['manualInput'];
  String? get selectLocation => _getLocalizedValues()['selectLocation'];


  // Operator [] funksiyasi (qulaylik uchun)
  String? operator [](String key) {
    return _getLocalizedValues()[key];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          (supportedLocale.countryCode == null ||
              supportedLocale.countryCode ==
                  locale.countryCode)); // Updated logic

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
