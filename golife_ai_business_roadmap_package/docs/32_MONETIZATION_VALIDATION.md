# 32 - Monetization Validation

Fecha: 2026-04-24

## Assumptions used

These are planning assumptions, not live market facts.

| Variable | Base assumption |
|---|---|
| Plus price | EUR 7.99 / month |
| AI cost per call | EUR 0.005 |
| Free user AI calls / month | 12 |
| Paid user AI calls / month | 90 |
| Free to paid conversion | 4% |
| Monthly churn | 7% |
| Support cost per paid user / month | EUR 0.80 |
| Shared infra / storage / misc per MAU | EUR 0.15 |

## Unit economics

### AI cost

- Free user AI cost: `12 * 0.005 = EUR 0.06`
- Paid user AI cost: `90 * 0.005 = EUR 0.45`

### Blended cost per MAU

Using 4% paid conversion:

- blended AI cost:
  - `0.96 * 0.06 = EUR 0.0576`
  - `0.04 * 0.45 = EUR 0.0180`
  - total AI = `EUR 0.0756`
- blended support cost:
  - `0.04 * 0.80 = EUR 0.0320`
- shared infra:
  - `EUR 0.15`

**Break-even ARPU floor = EUR 0.2576 per MAU**

## Revenue check

With Plus at EUR 7.99 and 4% conversion:

- blended subscription ARPU:
  - `0.04 * 7.99 = EUR 0.3196`

Indicative contribution margin per MAU:

- `0.3196 - 0.2576 = EUR 0.0620`

This is positive but still thin.
That means:

- free limits must stay tight;
- support burden must stay low;
- conversion must not underperform badly.

## Break-even conversion

If Plus is EUR 7.99:

- `0.2576 / 7.99 = 3.22%`

So the business roughly breaks even around **3.3% paid conversion** under the base assumptions.

If Plus were EUR 5.99:

- `0.2576 / 5.99 = 4.30%`

That leaves much less room for execution error.

## Recommendation

### Recommended Plus price

**EUR 7.99 / month**

Reason:

- gives margin room;
- still within impulse-subscription range for B2C productivity/wellbeing software;
- safer than EUR 5.99 under uncertain AI usage.

### Recommended free limits

- unlimited manual capture;
- 20 AI actions per month;
- no weekly AI review;
- no advanced cross-domain replay;
- keep core product useful without AI.

## Risks

### 1. AI overuse risk

If free users over-consume AI, ARPU collapses.

Mitigation:

- hard monthly cap;
- caching;
- aggressive mock/local fallback where possible.

### 2. Conversion risk

At <3.3% conversion, the model gets fragile fast.

Mitigation:

- tighter wedge;
- faster onboarding to first mission value;
- clearer paywall on AI synthesis, not on data ownership.

### 3. Support risk

Cross-domain AI products create trust and explanation questions.

Mitigation:

- clear trace;
- refusal language;
- human-readable explanation screen;
- conservative claims.

### 4. Churn risk

If missions feel generic, users will not keep paying.

Mitigation:

- optimize mission usefulness first;
- do not expand module count before the mission loop is strong.
