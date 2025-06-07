local Translations = {
    info = {
        seller = "تاجر الممنوعات",
        level = "المستوى: %{level}",
        xp = "الخبرة: %{current}/%{required}",
        level_up = "تهانينا! لقد وصلت إلى المستوى %{level}!",
        reward = "لقد حصلت على مكافأة للوصول إلى المستوى %{level}!",
        money_reward = "لقد حصلت على $%{amount} للوصول إلى المستوى %{level}!",
        item_reward = "لقد حصلت على %{amount}x %{item} للوصول إلى المستوى %{level}!",
        not_enough = "ليس لديك ما يكفي من هذا الغرض!",
        sold_item = "لقد بعت %{amount}x %{item} مقابل $%{price}",
        gained_xp = "لقد حصلت على %{xp} نقطة خبرة!",
        max_level = "لقد وصلت إلى الحد الأقصى للمستوى!",
        already_claimed = "لقد استلمت هذه المكافأة بالفعل!",
        reward_claimed = "تم استلام المكافأة بنجاح!",
    },
    menu = {
        title = "تاجر الممنوعات",
        rewards_title = "المكافآت",
        sell_items_title = "بيع الأغراض",
        subtitle = "بيع أغراضك مقابل المال",
        close = "إغلاق القائمة",
        back = "رجوع",
        sell_items = "بيع الأغراض",
        rewards = "استلام المكافآت",
        enter_amount = "أدخل الكمية المراد بيعها",
        price_per_item = "السعر: $%{price} لكل قطعة",
        total_price = "المجموع: $%{price}",
        level_bonus = "مكافأة المستوى: +%{bonus}%",
        your_level = "مستواك: %{level}",
        next_level = "المستوى التالي: %{xp}/%{required} خبرة",
        claim_reward = "استلام المكافأة",
        reward_level = "مكافأة المستوى %{level}",
        no_rewards = "لا توجد مكافآت متاحة",
        reach_higher = "وصول إلى مستويات أعلى لفتح المكافآت",
    }
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})