/*
 * Copyright (c) 2026
 *
 * SPDX-License-Identifier: MIT
 */

#define DT_DRV_COMPAT zmk_behavior_extended_caps_word

#include <zephyr/device.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/util.h>

#include <drivers/behavior.h>

#include <zmk/behavior.h>
#include <zmk/endpoints.h>
#include <zmk/event_manager.h>
#include <zmk/events/keycode_state_changed.h>
#include <zmk/events/modifiers_state_changed.h>
#include <zmk/events/position_state_changed.h>
#include <zmk/hid.h>
#include <zmk/keymap.h>
#include <zmk/keys.h>

LOG_MODULE_DECLARE(zmk, CONFIG_ZMK_LOG_LEVEL);

#if DT_HAS_COMPAT_STATUS_OKAY(DT_DRV_COMPAT)

/*
 * Derived from ZMK v0.3's stock Caps Word behavior and extended to treat
 * configured non-alpha HID key usages as "word" keys that also receive Shift.
 */

struct extended_caps_word_item {
    uint16_t page;
    uint32_t id;
    uint8_t implicit_modifiers;
};

struct behavior_extended_caps_word_config {
    zmk_mod_flags_t mods;
    const struct extended_caps_word_item *continuations;
    uint8_t continuations_count;
    const struct extended_caps_word_item *word_list;
    uint8_t word_list_count;
};

struct behavior_extended_caps_word_data {
    bool active;
};

static void activate_extended_caps_word(const struct device *dev) {
    struct behavior_extended_caps_word_data *data = dev->data;

    data->active = true;
}

static void deactivate_extended_caps_word(const struct device *dev) {
    struct behavior_extended_caps_word_data *data = dev->data;

    data->active = false;
}

static int on_extended_caps_word_binding_pressed(struct zmk_behavior_binding *binding,
                                                 struct zmk_behavior_binding_event event) {
    const struct device *dev = zmk_behavior_get_binding(binding->behavior_dev);
    struct behavior_extended_caps_word_data *data = dev->data;

    if (data->active) {
        deactivate_extended_caps_word(dev);
    } else {
        activate_extended_caps_word(dev);
    }

    return ZMK_BEHAVIOR_OPAQUE;
}

static int on_extended_caps_word_binding_released(struct zmk_behavior_binding *binding,
                                                  struct zmk_behavior_binding_event event) {
    return ZMK_BEHAVIOR_OPAQUE;
}

static const struct behavior_driver_api behavior_extended_caps_word_driver_api = {
    .binding_pressed = on_extended_caps_word_binding_pressed,
    .binding_released = on_extended_caps_word_binding_released,
#if IS_ENABLED(CONFIG_ZMK_BEHAVIOR_METADATA)
    .get_parameter_metadata = zmk_behavior_get_empty_param_metadata,
#endif
};

static int extended_caps_word_keycode_state_changed_listener(const zmk_event_t *eh);

ZMK_LISTENER(behavior_extended_caps_word, extended_caps_word_keycode_state_changed_listener);
ZMK_SUBSCRIPTION(behavior_extended_caps_word, zmk_keycode_state_changed);

#define GET_DEV(inst) DEVICE_DT_INST_GET(inst),
static const struct device *devs[] = {DT_INST_FOREACH_STATUS_OKAY(GET_DEV)};

static bool extended_caps_word_list_contains(const struct extended_caps_word_item *items,
                                             uint8_t item_count, uint16_t usage_page,
                                             uint8_t usage_id, uint8_t implicit_modifiers,
                                             const char *list_name) {
    for (int i = 0; i < item_count; i++) {
        const struct extended_caps_word_item *item = &items[i];
        LOG_DBG("%s: Comparing with 0x%02X - 0x%02X (with implicit mods: 0x%02X)", list_name,
                item->page, item->id, item->implicit_modifiers);

        if (item->page == usage_page && item->id == usage_id &&
            (item->implicit_modifiers & (implicit_modifiers | zmk_hid_get_explicit_mods())) ==
                item->implicit_modifiers) {
            LOG_DBG("%s: Found matching usage: 0x%02X - 0x%02X", list_name, usage_page, usage_id);
            return true;
        }
    }

    return false;
}

static bool extended_caps_word_is_continue_item(const struct behavior_extended_caps_word_config *config,
                                                uint16_t usage_page, uint8_t usage_id,
                                                uint8_t implicit_modifiers) {
    return extended_caps_word_list_contains(config->continuations, config->continuations_count,
                                            usage_page, usage_id, implicit_modifiers,
                                            "continue_list");
}

static bool extended_caps_word_is_word_item(const struct behavior_extended_caps_word_config *config,
                                            uint16_t usage_page, uint8_t usage_id,
                                            uint8_t implicit_modifiers) {
    return extended_caps_word_list_contains(config->word_list, config->word_list_count, usage_page,
                                            usage_id, implicit_modifiers, "word_list");
}

static bool extended_caps_word_is_alpha(uint8_t usage_id) {
    return (usage_id >= HID_USAGE_KEY_KEYBOARD_A && usage_id <= HID_USAGE_KEY_KEYBOARD_Z);
}

static bool extended_caps_word_is_numeric(uint8_t usage_id) {
    return (usage_id >= HID_USAGE_KEY_KEYBOARD_1_AND_EXCLAMATION &&
            usage_id <= HID_USAGE_KEY_KEYBOARD_0_AND_RIGHT_PARENTHESIS);
}

static void extended_caps_word_enhance_usage(const struct behavior_extended_caps_word_config *config,
                                             struct zmk_keycode_state_changed *ev,
                                             bool is_word_item) {
    if (ev->usage_page != HID_USAGE_KEY ||
        (!extended_caps_word_is_alpha(ev->keycode) && !is_word_item)) {
        return;
    }

    LOG_DBG("Enhancing usage 0x%02X with modifiers: 0x%02X", ev->keycode, config->mods);
    ev->implicit_modifiers |= config->mods;
}

static int extended_caps_word_keycode_state_changed_listener(const zmk_event_t *eh) {
    struct zmk_keycode_state_changed *ev = as_zmk_keycode_state_changed(eh);
    if (ev == NULL || !ev->state) {
        return ZMK_EV_EVENT_BUBBLE;
    }

    for (int i = 0; i < ARRAY_SIZE(devs); i++) {
        const struct device *dev = devs[i];
        struct behavior_extended_caps_word_data *data = dev->data;

        if (!data->active) {
            continue;
        }

        const struct behavior_extended_caps_word_config *config = dev->config;
        const bool is_alpha =
            ev->usage_page == HID_USAGE_KEY && extended_caps_word_is_alpha(ev->keycode);
        const bool is_numeric =
            ev->usage_page == HID_USAGE_KEY && extended_caps_word_is_numeric(ev->keycode);
        const bool is_word_item = extended_caps_word_is_word_item(
            config, ev->usage_page, ev->keycode, ev->implicit_modifiers);

        extended_caps_word_enhance_usage(config, ev, is_word_item);

        if (!is_alpha && !is_numeric && !is_word_item && !is_mod(ev->usage_page, ev->keycode) &&
            !extended_caps_word_is_continue_item(config, ev->usage_page, ev->keycode,
                                                 ev->implicit_modifiers)) {
            LOG_DBG("Deactivating extended_caps_word for 0x%02X - 0x%02X", ev->usage_page,
                    ev->keycode);
            deactivate_extended_caps_word(dev);
        }
    }

    return ZMK_EV_EVENT_BUBBLE;
}

#define PARSE_ITEM(i)                                                                              \
    {.page = ZMK_HID_USAGE_PAGE(i), .id = ZMK_HID_USAGE_ID(i), .implicit_modifiers = SELECT_MODS(i)}

#define CONTINUE_ITEM(i, n) PARSE_ITEM(DT_INST_PROP_BY_IDX(n, continue_list, i))
#define WORD_ITEM(i, n) PARSE_ITEM(DT_INST_PROP_BY_IDX(n, word_list, i))

#define EXTENDED_CAPS_WORD_INST(n)                                                                 \
    static const struct extended_caps_word_item                                                    \
        behavior_extended_caps_word_continuations_##n[] = {                                        \
            LISTIFY(DT_INST_PROP_LEN(n, continue_list), CONTINUE_ITEM, (, ), n)};                 \
    static const struct extended_caps_word_item behavior_extended_caps_word_word_list_##n[] = {    \
        LISTIFY(DT_INST_PROP_LEN(n, word_list), WORD_ITEM, (, ), n)};                             \
    static struct behavior_extended_caps_word_data behavior_extended_caps_word_data_##n = {        \
        .active = false,                                                                           \
    };                                                                                             \
    static const struct behavior_extended_caps_word_config behavior_extended_caps_word_config_##n = { \
        .mods = DT_INST_PROP_OR(n, mods, MOD_LSFT),                                                \
        .continuations = behavior_extended_caps_word_continuations_##n,                            \
        .continuations_count = ARRAY_SIZE(behavior_extended_caps_word_continuations_##n),          \
        .word_list = behavior_extended_caps_word_word_list_##n,                                    \
        .word_list_count = ARRAY_SIZE(behavior_extended_caps_word_word_list_##n),                  \
    };                                                                                             \
    BEHAVIOR_DT_INST_DEFINE(n, NULL, NULL, &behavior_extended_caps_word_data_##n,                  \
                            &behavior_extended_caps_word_config_##n, POST_KERNEL,                  \
                            CONFIG_KERNEL_INIT_PRIORITY_DEFAULT,                                   \
                            &behavior_extended_caps_word_driver_api);

DT_INST_FOREACH_STATUS_OKAY(EXTENDED_CAPS_WORD_INST)

#endif
