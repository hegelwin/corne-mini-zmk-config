"""Check the shared firmware/macOS contract for plus and hard sign.

Run with: python3 tests/russian-universal/test_keypad_plus.py
"""

import html
from pathlib import Path
import re
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
LAYOUT = ROOT / "os-keymap/Russian Universal.bundle/Contents/Resources/Russian \u2013 Universal.keylayout"


class KeypadPlusTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # macOS layouts allow control-character references that XML 1.0 rejects.
        # Preserve references as text while parsing, then decode key outputs.
        source = re.sub(r"&#(x[0-9A-Fa-f]+|\d+);", r"&amp;#\1;", LAYOUT.read_text(encoding="utf-8"))
        layout = ET.fromstring(source)
        cls.map_sets = {
            node.get("id"): {
                int(key_map.get("index")): key_map for key_map in node.findall("keyMap")
            }
            for node in layout.findall("keyMapSet")
        }
        cls.keymap = (ROOT / "config/corne_choc.keymap").read_text(encoding="utf-8")

    def output(self, map_set, index, code):
        key_map = self.map_sets[map_set][index]
        key = key_map.find(f"key[@code='{code}']")
        if key is not None:
            return html.unescape(key.get("output"))
        return self.output(key_map.get("baseMapSet"), int(key_map.get("baseIndex")), code)

    def test_keypad_plus_and_hard_sign_in_every_keyboard_variant(self):
        for map_set in self.map_sets:
            for index in self.map_sets[map_set]:
                expected = {3: "\u044a", 4: "\u042a", 9: "\u042a"}.get(index, "+")
                with self.subTest(map_set=map_set, index=index):
                    self.assertEqual(self.output(map_set, index, 69), expected)

    def test_firmware_uses_matching_keypad_slots(self):
        num_layer = re.search(r"num_layer\s*\{(.*?)\n\s*\};", self.keymap, re.S).group(1)
        self.assertRegex(num_layer, r"&kp KP_N9\s+&kp KP_PLUS\b")
        self.assertIn("&ru_uni_m_hard_sign_ht LA(KP_PLUS) M", self.keymap)
        self.assertNotIn("&kp KP_ENTER", self.keymap)

    def test_caps_word_only_treats_modified_plus_as_a_letter(self):
        word_list = re.search(r"word-list\s*=\s*<(.*?)>;", self.keymap, re.S).group(1)
        self.assertIn("LA(KP_PLUS)", word_list.split())
        self.assertNotIn("KP_PLUS", word_list.split())

    def test_uppercase_zhe_remains_available(self):
        for map_set in self.map_sets:
            with self.subTest(map_set=map_set):
                self.assertEqual(self.output(map_set, 5, 24), "\u0436")
                self.assertEqual(self.output(map_set, 1, 24), "\u0416")


if __name__ == "__main__":
    unittest.main()
