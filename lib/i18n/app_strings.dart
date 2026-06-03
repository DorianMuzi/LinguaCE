import 'locale_controller.dart';

/// Traduit une clé dans la langue d'interface courante.
///
/// [params] permet l'interpolation : `tr('home.streak', {'n': '3'})`
/// remplace `{n}` par `3`. Repli sur le français si la traduction manque.
///
/// ⚠️ Les traductions tchétchènes (CE) sont fournies en **best-effort**
/// (système latin Muziŋ Dar) et méritent une relecture par un locuteur.
String tr(String key, [Map<String, String>? params]) {
  final lang = localeController.value;
  final entry = _strings[key];
  var s = entry?[lang] ?? entry?['FR'] ?? key;
  if (params != null) {
    params.forEach((k, v) => s = s.replaceAll('{$k}', v));
  }
  return s;
}

const Map<String, Map<String, String>> _strings = {
  // ── Navigation ────────────────────────────────────────────────────────────
  'nav.home': {'FR': 'Accueil', 'EN': 'Home', 'RU': 'Главная', 'CE': 'Ċa'},
  'nav.chat': {'FR': 'Chat', 'EN': 'Chat', 'RU': 'Чат', 'CE': 'Qamel'},
  'nav.learn': {'FR': 'Apprendre', 'EN': 'Learn', 'RU': 'Учить', 'CE': 'Jamar'},
  'nav.progress':
      {'FR': 'Progrès', 'EN': 'Progress', 'RU': 'Прогресс', 'CE': 'Progress'},

  // ── Titres d'écran ────────────────────────────────────────────────────────
  'title.chat':
      {'FR': 'Chat IA', 'EN': 'AI Chat', 'RU': 'ИИ-чат', 'CE': 'AI Qamel'},
  'title.learn':
      {'FR': 'Apprendre', 'EN': 'Learn', 'RU': 'Учить', 'CE': 'Jamar'},
  'title.progress':
      {'FR': 'Progrès', 'EN': 'Progress', 'RU': 'Прогресс', 'CE': 'Progress'},
  'title.profile':
      {'FR': 'Profil', 'EN': 'Profile', 'RU': 'Профиль', 'CE': 'Profil'},

  // ── Commun ────────────────────────────────────────────────────────────────
  'common.cancel':
      {'FR': 'Annuler', 'EN': 'Cancel', 'RU': 'Отмена', 'CE': 'Voça'},
  'common.save':
      {'FR': 'Enregistrer', 'EN': 'Save', 'RU': 'Сохранить', 'CE': 'Ç̇aġde'},
  'common.close':
      {'FR': 'Fermer', 'EN': 'Close', 'RU': 'Закрыть', 'CE': 'Dʼaqovla'},
  'common.delete':
      {'FR': 'Effacer', 'EN': 'Delete', 'RU': 'Удалить', 'CE': 'Dʼayaqqa'},
  'common.continue':
      {'FR': 'Continuer', 'EN': 'Continue', 'RU': 'Продолжить', 'CE': 'Dʼaxoʼla'},
  'common.soon': {
    'FR': 'Bientôt disponible !',
    'EN': 'Coming soon!',
    'RU': 'Скоро!',
    'CE': 'Sihha xir du!'
  },

  // ── Accueil ───────────────────────────────────────────────────────────────
  'home.greeting_morning':
      {'FR': 'Bonjour', 'EN': 'Good morning', 'RU': 'Доброе утро', 'CE': 'De dika'},
  'home.greeting_afternoon': {
    'FR': 'Bon après-midi',
    'EN': 'Good afternoon',
    'RU': 'Добрый день',
    'CE': 'De dika'
  },
  'home.greeting_evening':
      {'FR': 'Bonsoir', 'EN': 'Good evening', 'RU': 'Добрый вечер', 'CE': 'Süyre dika'},
  'home.streak_days': {
    'FR': '{n} jours consécutifs',
    'EN': '{n} day streak',
    'RU': '{n} дней подряд',
    'CE': '{n} de tʼayʼaza'
  },
  'home.streak_keep': {
    'FR': 'Continue comme ça !',
    'EN': 'Keep it up!',
    'RU': 'Так держать!',
    'CE': 'Dʼaxoʼla iştta!'
  },
  'home.streak_start': {
    'FR': 'Commence ta série !',
    'EN': 'Start your streak!',
    'RU': 'Начни свою серию!',
    'CE': 'Xahʼa dolade!'
  },
  'home.record': {'FR': 'Record', 'EN': 'Record', 'RU': 'Рекорд', 'CE': 'Rekord'},
  'home.quick_actions': {
    'FR': 'Actions rapides',
    'EN': 'Quick actions',
    'RU': 'Быстрые действия',
    'CE': 'Sihha gʼullaqş'
  },
  'home.qa_chat': {'FR': 'Chat IA', 'EN': 'AI Chat', 'RU': 'ИИ-чат', 'CE': 'AI Qamel'},
  'home.qa_lessons':
      {'FR': 'Leçons', 'EN': 'Lessons', 'RU': 'Уроки', 'CE': 'Deşarş'},
  'home.qa_progress':
      {'FR': 'Progrès', 'EN': 'Progress', 'RU': 'Прогресс', 'CE': 'Progress'},
  'home.daily_lesson': {
    'FR': 'Leçon du jour',
    'EN': 'Daily lesson',
    'RU': 'Урок дня',
    'CE': 'Tahanlera deşar'
  },
  'home.word_of_day': {
    'FR': 'Mot du jour',
    'EN': 'Word of the day',
    'RU': 'Слово дня',
    'CE': 'Tahanlera doş'
  },
  'home.word_desc': {
    'FR': '"Merci" — Expression de gratitude en tchétchène.',
    'EN': '"Thank you" — An expression of gratitude in Chechen.',
    'RU': '«Спасибо» — выражение благодарности на чеченском.',
    'CE': '"Barkalla" — bart boçu doş noxçiyn matte.'
  },

  // ── Apprendre ─────────────────────────────────────────────────────────────
  'learn.title1': {'FR': 'Apprendre', 'EN': 'Learn', 'RU': 'Учить', 'CE': 'Jamabe'},
  'learn.title2': {
    'FR': 'le tchétchène',
    'EN': 'Chechen',
    'RU': 'чеченский',
    'CE': 'noxçiyŋ mott'
  },
  'learn.path': {
    'FR': 'Parcours d\'apprentissage',
    'EN': 'Learning path',
    'RU': 'Программа обучения',
    'CE': 'Jamaraŋ neq'
  },
  'learn.lessons_count': {
    'FR': '{c} / {t} leçons',
    'EN': '{c} / {t} lessons',
    'RU': '{c} / {t} уроков',
    'CE': '{c} / {t} deşar'
  },
  'learn.completed': {
    'FR': 'complétées',
    'EN': 'completed',
    'RU': 'завершено',
    'CE': 'çekxdäxna'
  },
  'learn.beginner':
      {'FR': 'Débutant', 'EN': 'Beginner', 'RU': 'Новичок', 'CE': 'Dolalurg'},
  'learn.finished':
      {'FR': 'Terminé', 'EN': 'Finished', 'RU': 'Завершено', 'CE': 'Çekxdälla'},
  'learn.in_progress':
      {'FR': 'EN COURS', 'EN': 'IN PROGRESS', 'RU': 'В ПРОЦЕССЕ', 'CE': 'DʼAXO'},
  'learn.exercises_count': {
    'FR': '{c}/{t} exercices',
    'EN': '{c}/{t} exercises',
    'RU': '{c}/{t} упражнений',
    'CE': '{c}/{t} bolx'
  },
  'learn.start':
      {'FR': 'Commencer', 'EN': 'Start', 'RU': 'Начать', 'CE': 'Dʼadolade'},
  'learn.review':
      {'FR': 'Revoir', 'EN': 'Review', 'RU': 'Повторить', 'CE': 'Yuxaxaʼa'},

  // ── Progrès ───────────────────────────────────────────────────────────────
  'progress.title':
      {'FR': 'Mes progrès', 'EN': 'My progress', 'RU': 'Мой прогресс', 'CE': 'Saŋ progress'},
  'progress.this_week': {
    'FR': 'Cette semaine',
    'EN': 'This week',
    'RU': 'На этой неделе',
    'CE': 'Hʼokxu kʼira'
  },
  'progress.week_xp': {
    'FR': 'cette semaine',
    'EN': 'this week',
    'RU': 'за неделю',
    'CE': 'hʼokxu kʼira'
  },
  'progress.league':
      {'FR': 'Ligue {l}', 'EN': 'League {l}', 'RU': 'Лига {l}', 'CE': 'Liga {l}'},
  'progress.stats': {
    'FR': 'Mes statistiques',
    'EN': 'My stats',
    'RU': 'Моя статистика',
    'CE': 'Saŋ statistika'
  },
  'progress.empty_league': {
    'FR': 'Aucun classement pour l\'instant.',
    'EN': 'No ranking yet.',
    'RU': 'Пока нет рейтинга.',
    'CE': 'Hʼinca classement yac.'
  },
  'stat.streak': {'FR': 'SÉRIE', 'EN': 'STREAK', 'RU': 'СЕРИЯ', 'CE': 'TʼAY'},
  'stat.xp_total':
      {'FR': 'XP TOTAL', 'EN': 'TOTAL XP', 'RU': 'ВСЕГО XP', 'CE': 'XP DʼOG'},
  'stat.level': {'FR': 'NIVEAU', 'EN': 'LEVEL', 'RU': 'УРОВЕНЬ', 'CE': 'TʼEMA'},
  'stat.lessons':
      {'FR': 'LEÇONS', 'EN': 'LESSONS', 'RU': 'УРОКИ', 'CE': 'DEŞARŞ'},

  // ── Profil ────────────────────────────────────────────────────────────────
  'profile.edit_name': {
    'FR': 'Modifier le nom',
    'EN': 'Edit name',
    'RU': 'Изменить имя',
    'CE': 'Ċe hʼaşdo'
  },
  'profile.username': {
    'FR': 'Nom d\'utilisateur',
    'EN': 'Username',
    'RU': 'Имя пользователя',
    'CE': 'Deq̇aşxoçuŋ ċe'
  },
  'profile.logout_q': {
    'FR': 'Se déconnecter ?',
    'EN': 'Log out?',
    'RU': 'Выйти?',
    'CE': 'Aravala?'
  },
  'profile.logout_desc': {
    'FR': 'Tu devras te reconnecter pour accéder à ton profil.',
    'EN': 'You\'ll need to sign in again to access your profile.',
    'RU': 'Нужно будет войти снова, чтобы открыть профиль.',
    'CE': 'Profile da hʼotta yuxa çuvala deza hʼuna.'
  },
  'profile.logout': {
    'FR': 'Déconnecter',
    'EN': 'Log out',
    'RU': 'Выйти',
    'CE': 'Aravala'
  },
  'profile.logout_btn': {
    'FR': 'Se déconnecter',
    'EN': 'Log out',
    'RU': 'Выйти',
    'CE': 'Aravala'
  },
  'profile.days': {'FR': 'jours', 'EN': 'days', 'RU': 'дней', 'CE': 'de'},
  'profile.day': {'FR': 'jour', 'EN': 'day', 'RU': 'день', 'CE': 'de'},
  'set.notifications': {
    'FR': 'Notifications',
    'EN': 'Notifications',
    'RU': 'Уведомления',
    'CE': 'Xaamş'
  },
  'set.interface_lang': {
    'FR': 'Langue de l\'interface',
    'EN': 'Interface language',
    'RU': 'Язык интерфейса',
    'CE': 'Interfaceaŋ mott'
  },
  'set.sounds': {'FR': 'Sons', 'EN': 'Sounds', 'RU': 'Звуки', 'CE': 'Ozaş'},
  'set.privacy': {
    'FR': 'Confidentialité',
    'EN': 'Privacy',
    'RU': 'Конфиденциальность',
    'CE': 'Bʼobʼalla'
  },
  'set.help': {
    'FR': 'Aide & Support',
    'EN': 'Help & Support',
    'RU': 'Помощь',
    'CE': 'Gʼo & Dʼadar'
  },

  // ── Menu latéral (drawer) ─────────────────────────────────────────────────
  'drawer.tagline': {
    'FR': 'Apprendre le tchétchène',
    'EN': 'Learn Chechen',
    'RU': 'Учить чеченский',
    'CE': 'Noxçiyŋ mott jamabe'
  },
  'drawer.home': {'FR': 'Accueil', 'EN': 'Home', 'RU': 'Главная', 'CE': 'Ċa'},
  'drawer.about':
      {'FR': 'À propos', 'EN': 'About', 'RU': 'О приложении', 'CE': 'Lerina'},
  'drawer.theme': {
    'FR': 'Thème sombre',
    'EN': 'Dark theme',
    'RU': 'Тёмная тема',
    'CE': 'Bʼarža tema'
  },
  'drawer.share': {
    'FR': 'Partager l\'app',
    'EN': 'Share the app',
    'RU': 'Поделиться',
    'CE': 'App dʼayʼa'
  },
  'drawer.profile_meta': {
    'FR': '{emoji} Niveau {l} · Ligue {league}',
    'EN': '{emoji} Level {l} · {league} League',
    'RU': '{emoji} Уровень {l} · Лига {league}',
    'CE': '{emoji} Tʼema {l} · Liga {league}'
  },
  'about.version':
      {'FR': 'Version 1.0.0', 'EN': 'Version 1.0.0', 'RU': 'Версия 1.0.0', 'CE': 'Version 1.0.0'},
  'about.desc': {
    'FR':
        'LinguaCE est une application mobile d\'apprentissage de la langue tchétchène (нохчийн мотт) assistée par intelligence artificielle.',
    'EN':
        'LinguaCE is a mobile app for learning the Chechen language (нохчийн мотт), powered by artificial intelligence.',
    'RU':
        'LinguaCE — мобильное приложение для изучения чеченского языка (нохчийн мотт) с помощью искусственного интеллекта.',
    'CE':
        'LinguaCE — noxçiyŋ mott jamabaŋ mobiltelefonaŋ programma yu, AI gʼoʼaca.'
  },
  'about.made': {
    'FR': 'Développée avec ❤️ pour préserver et diffuser la langue tchétchène.',
    'EN': 'Built with ❤️ to preserve and spread the Chechen language.',
    'RU': 'Сделано с ❤️, чтобы сохранять и распространять чеченский язык.',
    'CE': 'Noxçiyŋ mott lardaŋ ❤️-ca yina.'
  },
  'lang.selected': {
    'FR': '{lang} sélectionné',
    'EN': '{lang} selected',
    'RU': 'Выбран {lang}',
    'CE': '{lang} xʼaržina'
  },

  // ── Chat ──────────────────────────────────────────────────────────────────
  'chat.language': {'FR': 'Langue :', 'EN': 'Language:', 'RU': 'Язык:', 'CE': 'Mott:'},
  'chat.ai_label': {
    'FR': 'IA Tchétchène',
    'EN': 'Chechen AI',
    'RU': 'Чеченский ИИ',
    'CE': 'Noxçiyŋ AI'
  },
  'chat.clear_q': {
    'FR': 'Effacer la conversation ?',
    'EN': 'Clear the conversation?',
    'RU': 'Очистить переписку?',
    'CE': 'Qamel dʼadaqqa?'
  },
  'chat.clear_desc': {
    'FR': 'L\'historique sera supprimé définitivement.',
    'EN': 'The history will be permanently deleted.',
    'RU': 'История будет удалена навсегда.',
    'CE': 'Istori dʼayaqqa yʼür yu.'
  },
  'chat.hint': {
    'FR': 'Écrivez votre message...',
    'EN': 'Type your message...',
    'RU': 'Напишите сообщение...',
    'CE': 'Hʼaŋ xaam yazde...'
  },
  'chat.copy': {
    'FR': 'Copier le texte',
    'EN': 'Copy text',
    'RU': 'Копировать текст',
    'CE': 'Tekst kopde'
  },
  'chat.edit': {'FR': 'Modifier', 'EN': 'Edit', 'RU': 'Изменить', 'CE': 'Hʼaşdo'},
  'chat.regenerate': {
    'FR': 'Régénérer la réponse',
    'EN': 'Regenerate response',
    'RU': 'Сгенерировать заново',
    'CE': 'Juxa kxolla'
  },
  'chat.copied': {
    'FR': 'Texte copié',
    'EN': 'Text copied',
    'RU': 'Текст скопирован',
    'CE': 'Tekst kopdina'
  },

  // ── Erreurs / validations communes ────────────────────────────────────────
  'err.fill_fields': {
    'FR': 'Veuillez remplir tous les champs.',
    'EN': 'Please fill in all fields.',
    'RU': 'Заполните все поля.',
    'CE': 'Massa mettigaş dʼayazde.'
  },
  'err.generic': {
    'FR': 'Une erreur est survenue. Réessaie.',
    'EN': 'Something went wrong. Try again.',
    'RU': 'Произошла ошибка. Попробуйте снова.',
    'CE': 'Gʼalat xilla. Yuxa gʼort.'
  },

  // ── Exercices ─────────────────────────────────────────────────────────────
  'ex.tap_flip': {
    'FR': 'Tapez la carte pour la retourner',
    'EN': 'Tap the card to flip it',
    'RU': 'Нажмите на карточку, чтобы перевернуть',
    'CE': 'Kart juxaerza tʼeqʼa'
  },
  'ex.tap_translate': {
    'FR': 'Tapez pour voir la traduction',
    'EN': 'Tap to see the translation',
    'RU': 'Нажмите, чтобы увидеть перевод',
    'CE': 'Goçyar gayta tʼeqʼa'
  },
  'ex.understood': {
    'FR': 'J\'ai compris → +5 XP',
    'EN': 'Got it → +5 XP',
    'RU': 'Понятно → +5 XP',
    'CE': 'Kxiʼti → +5 XP'
  },
  'ex.next': {'FR': 'Suivant →', 'EN': 'Next →', 'RU': 'Дальше →', 'CE': 'Dʼaxo →'},
  'ex.finish': {
    'FR': 'Terminer la leçon 🎓',
    'EN': 'Finish the lesson 🎓',
    'RU': 'Завершить урок 🎓',
    'CE': 'Deşar çekxdaqqa 🎓'
  },
  'ex.hint': {
    'FR': '💡 Indice : {x}',
    'EN': '💡 Hint: {x}',
    'RU': '💡 Подсказка: {x}',
    'CE': '💡 Gʼo: {x}'
  },
  'ex.answer_hint': {
    'FR': 'Ta réponse en cyrillique…',
    'EN': 'Your answer in Cyrillic…',
    'RU': 'Ваш ответ кириллицей…',
    'CE': 'Hʼaŋ juʼp cirilliyca…'
  },
  'ex.check': {'FR': 'Vérifier', 'EN': 'Check', 'RU': 'Проверить', 'CE': 'Talla'},
  'ex.perfect': {
    'FR': '🎉 Parfait !',
    'EN': '🎉 Perfect!',
    'RU': '🎉 Отлично!',
    'CE': '🎉 Dika!'
  },
  'ex.correct_answer': {
    'FR': '💡 La bonne réponse :',
    'EN': '💡 The correct answer:',
    'RU': '💡 Правильный ответ:',
    'CE': '💡 Nisa juʼp:'
  },
  'ex.correct':
      {'FR': 'Correct !', 'EN': 'Correct!', 'RU': 'Верно!', 'CE': 'Nisa!'},
  'ex.not_quite': {
    'FR': 'Pas tout à fait…',
    'EN': 'Not quite…',
    'RU': 'Не совсем…',
    'CE': 'Dац iştta…'
  },
  'ex.answer_is': {
    'FR': 'Réponse : {x}',
    'EN': 'Answer: {x}',
    'RU': 'Ответ: {x}',
    'CE': 'Juʼp: {x}'
  },
  'ex.done_perfect':
      {'FR': 'Parfait !', 'EN': 'Perfect!', 'RU': 'Отлично!', 'CE': 'Dika!'},
  'ex.done': {
    'FR': 'Leçon terminée !',
    'EN': 'Lesson complete!',
    'RU': 'Урок завершён!',
    'CE': 'Deşar çekxdälla!'
  },
  'ex.xp_earned':
      {'FR': 'XP gagnés', 'EN': 'XP earned', 'RU': 'Получено XP', 'CE': 'XP qaʼchina'},
  'ex.mistakes':
      {'FR': 'Erreurs', 'EN': 'Mistakes', 'RU': 'Ошибки', 'CE': 'Gʼalataş'},
  'ex.exercises':
      {'FR': 'Exercices', 'EN': 'Exercises', 'RU': 'Упражнения', 'CE': 'Bolxaş'},

  // ── Mot de passe oublié ───────────────────────────────────────────────────
  'forgot.title': {
    'FR': 'Mot de passe oublié ?',
    'EN': 'Forgot password?',
    'RU': 'Забыли пароль?',
    'CE': 'Doġanaŋ doş dicdella?'
  },
  'forgot.desc': {
    'FR':
        'Saisis ton adresse email et nous t\'enverrons un lien pour réinitialiser ton mot de passe.',
    'EN':
        'Enter your email and we\'ll send you a link to reset your password.',
    'RU':
        'Введите email — мы отправим ссылку для сброса пароля.',
    'CE':
        'Hʼaŋ elektronni poşt yazde, doş juxametta link dʼahʼür du oxa hʼuna.'
  },
  'forgot.email': {
    'FR': 'Adresse email',
    'EN': 'Email address',
    'RU': 'Электронная почта',
    'CE': 'Elektronni poşt'
  },
  'forgot.send': {
    'FR': 'Envoyer le lien',
    'EN': 'Send the link',
    'RU': 'Отправить ссылку',
    'CE': 'Link dʼahʼa'
  },
  'forgot.back': {
    'FR': 'Retour à la connexion',
    'EN': 'Back to sign in',
    'RU': 'Назад ко входу',
    'CE': 'Çuvaxare juxa'
  },
  'forgot.sent_title': {
    'FR': 'Email envoyé !',
    'EN': 'Email sent!',
    'RU': 'Письмо отправлено!',
    'CE': 'Email dʼahʼna!'
  },
  'forgot.sent_to': {
    'FR': 'Un lien de réinitialisation a été envoyé à :',
    'EN': 'A reset link has been sent to:',
    'RU': 'Ссылка для сброса отправлена на:',
    'CE': 'Juxametta link dʼahʼna:'
  },
  'forgot.check_inbox': {
    'FR':
        'Vérifie ta boîte de réception (et tes spams) puis clique sur le lien pour choisir un nouveau mot de passe.',
    'EN':
        'Check your inbox (and spam) then click the link to choose a new password.',
    'RU':
        'Проверьте почту (и спам), затем нажмите на ссылку, чтобы задать новый пароль.',
    'CE':
        'Hʼaŋ poşt talla (spam a), tʼaqqa link tʼeqʼa kerla doş xʼarža.'
  },
  'forgot.other_email': {
    'FR': 'Utiliser une autre adresse',
    'EN': 'Use another address',
    'RU': 'Использовать другой адрес',
    'CE': 'Kxin adres lela'
  },
  'forgot.err_empty': {
    'FR': 'Veuillez entrer votre adresse email.',
    'EN': 'Please enter your email address.',
    'RU': 'Введите ваш email.',
    'CE': 'Hʼaŋ elektronni poşt yazde.'
  },
  'forgot.err_invalid': {
    'FR': 'Adresse email invalide.',
    'EN': 'Invalid email address.',
    'RU': 'Неверный email.',
    'CE': 'Elektronni poşt nisa yac.'
  },
};
