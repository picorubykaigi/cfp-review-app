window.cfpValuesBody = function (a, b, c, d, e) {
  return JSON.stringify({ values: [[a, b, c, d, e]] });
};

window.cfpNow = function () {
  return new Date().toISOString();
};

// GIS のトークンクライアント。requestAccessToken() は
// ポップアップを出すのでユーザー操作の中から呼ぶ必要がある。
window.cfpSignIn = function (callback) {
  if (!window.CFP_CLIENT_ID) { callback(''); return; }
  try {
    var client = google.accounts.oauth2.initTokenClient({
      client_id: window.CFP_CLIENT_ID,
      scope: window.CFP_SCOPES,
      callback: function (res) { callback(res && res.access_token ? res.access_token : ''); },
      error_callback: function () { callback(''); }
    });
    client.requestAccessToken();
  } catch (e) {
    callback('');
  }
};

window.cfpPushState = function () {
  history.pushState({ cfp: 1 }, '', location.href);
};

window.cfpBack = function () { history.back(); };
