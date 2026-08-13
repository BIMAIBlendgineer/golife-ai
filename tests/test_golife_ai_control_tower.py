import unittest
from unittest.mock import patch

import golife_ai


class GoLifeControlTowerTests(unittest.TestCase):
    def test_backend_env_advertises_detected_lan_gateway(self):
        with patch.object(
            golife_ai.GoLifeControlTower,
            "_detect_lan_host",
            return_value="192.168.50.10",
        ):
            tower = golife_ai.GoLifeControlTower()

        self.assertEqual(tower.lan_host, "192.168.50.10")
        self.assertEqual(
            tower.services["BACKEND"].env["MOBILE_GATEWAY_BASE_URL"],
            "http://192.168.50.10:3062",
        )
        self.assertEqual(
            tower._mobile_gateway_base_url(),
            "http://192.168.50.10:3062",
        )

    def test_physical_mobile_and_runtime_config_use_same_lan_gateway(self):
        captured = []
        with (
            patch.object(
                golife_ai.GoLifeControlTower,
                "_detect_lan_host",
                return_value="192.168.50.10",
            ),
            patch.object(
                golife_ai.GoLifeControlTower,
                "validate_repo_context",
                return_value=True,
            ),
            patch.object(
                golife_ai.GoLifeControlTower,
                "_pick_mobile_flutter_device",
                return_value={"id": "adb-test-device", "emulator": False},
            ),
        ):
            tower = golife_ai.GoLifeControlTower()
            with patch.object(tower, "_spawn", side_effect=captured.append):
                tower.start_mobile()

        self.assertEqual(len(captured), 1)
        mobile_config = captured[0]
        self.assertIn(
            "--dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://192.168.50.10:3062",
            mobile_config.cmd,
        )
        self.assertIn(
            "--dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://192.168.50.10:3061",
            mobile_config.cmd,
        )
        self.assertEqual(
            tower.services["BACKEND"].env["MOBILE_GATEWAY_BASE_URL"],
            "http://192.168.50.10:3062",
        )

    def test_backend_never_advertises_bind_host_when_lan_is_known(self):
        with patch.object(
            golife_ai.GoLifeControlTower,
            "_detect_lan_host",
            return_value="192.168.50.10",
        ):
            tower = golife_ai.GoLifeControlTower()

        advertised = tower.services["BACKEND"].env["MOBILE_GATEWAY_BASE_URL"]
        for forbidden_host in ("0.0.0.0", "127.0.0.1", "localhost"):
            self.assertNotIn(forbidden_host, advertised)


if __name__ == "__main__":
    unittest.main()
