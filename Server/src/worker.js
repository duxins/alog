addEventListener('fetch', event => {
    event.respondWith(handleRequest(event.request).catch(e => {
        console.error(e.stack);
        return errorResponse(500)
    }))
})

async function handleRequest(request) {
    const url = new URL(request.url)
    const method = request.method

    if (request.method === 'POST') {
        const clone = request.clone();
        const arrayBuffer = await clone.arrayBuffer();
        if (arrayBuffer.byteLength > 1024 * 1024 * 4) {
          return errorResponse(413, 'Content too large')
        }
    }

    const key = request.headers.get('Authorization')?.replace('Bearer ', '') || randomKey()
    if (!key) { return errorResponse(401, 'Authorization Key is missing') }

    if (typeof HMAC_KEY != "undefined") {
        const request_id = request.headers.get('x-alog-request-id')
        const client_hmac = request.headers.get('x-alog-hmac')

        if (!request_id || !client_hmac) {
            return errorResponse(403, 'Authentication code is missing')
        }

        const hmac = await calculateHMAC(request_id);

        if (hmac != client_hmac) {
            return errorResponse(403, 'HMAC validation failed')
        }
    }

    const headers = generateHeaders(request, key)

    if (url.pathname.startsWith('/v1/audio/transcriptions') && method == 'POST') {
        return handleWhisperRequest(request, headers)
    } else if (url.pathname === '/v1/chat/completions' && method == 'POST') {
        return handleSummaryRequest(request, headers)
    } else {
        return errorResponse(404)
    }
}

async function calculateHMAC(message) {
    const encoder = new TextEncoder();
    const keyData = encoder.encode(HMAC_KEY);
    const msgData = encoder.encode(message);

    const key = await crypto.subtle.importKey(
        "raw", keyData, { name: "HMAC", hash: "SHA-256" }, false, ["sign"]
    );

    const hmacDigest = await crypto.subtle.sign("HMAC", key, msgData);

    return arrayBufferToBase64(hmacDigest);
}

function arrayBufferToBase64(buffer) {
    var binary = '';
    var bytes = new Uint8Array(buffer);
    var len = bytes.byteLength;
    for (var i = 0; i < len; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
}

function randomKey() {
    const keys = typeof OPENAI_KEY !== "undefined" ? OPENAI_KEY.split(',') : [];
    if (keys.length == 0) { return ''; }
    return keys[Math.floor(Math.random() * keys.length)];
}

function generateHeaders(request, key) {
    const contentType = request.headers.get("Content-Type")
    const ret = new Headers()
    ret.append("Authorization", `Bearer ${key}`)
    ret.append("Content-Type", contentType)
    return ret
}

async function handleWhisperRequest(request, headers) {
    const newRequest = new Request('https://api.openai.com/v1/audio/transcriptions', {
        method: "POST",
        headers: headers,
        body: request.body
    });

    const response = await fetch(newRequest);

    return await modifyResponse(response)
}

async function handleSummaryRequest(request, headers) {
    const requestBody = await request.json();
    if (requestBody.messages && requestBody.messages.length > 1) {
        requestBody.messages = [requestBody.messages[0]]
    }
    requestBody.model = typeof AI_MODEL !== "undefined" ? AI_MODEL : requestBody.model
    const newRequest = new Request('https://api.openai.com/v1/chat/completions', {
        method: "POST",
        headers: headers,
        body: JSON.stringify(requestBody),
    });
    const response = await fetch(newRequest);
    return await modifyResponse(response)
}

async function modifyResponse(response) {
    const ret = new Response(response.body, response);
    const excludedHeaders = [
        "x-request-id",
        "x-ratelimit-limit-tokens",
        "x-ratelimit-remaining-tokens",
        "x-ratelimit-reset-tokens",
        "x-ratelimit-limit-requests",
        "x-ratelimit-remaining-requests",
        "x-ratelimit-reset-requests",
        "openai-version",
        "openai-organization"
    ]
    excludedHeaders.forEach(key => {
        ret.headers.delete(key);
    });

    if ([401, 403, 404, 429].includes(response.status)) {
        console.error(await response.text())
        return errorResponse(response.status)
    }

    return ret
}

function errorResponse(status = 400, message = "") {
    const map = {
        400: "Bad Request",
        401: "Unauthorized",
        403: "Forbidden",
        404: "Not Found",
        429: "Too Many Requests",
        500: "Internal Server Error",
        503: "Service Unavailable",
    };

    if (!message) {
        message = map[status] || "An error occurred";
    }

    return new Response(
        JSON.stringify({
            error: {
                message: message,
                code: `${status}`
            }
        }),
        { status: status, headers: { "Content-Type": "application/json" } }
    );
}