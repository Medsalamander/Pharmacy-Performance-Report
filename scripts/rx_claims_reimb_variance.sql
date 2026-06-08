

SELECT 
	PAYER_NAME,
	COUNT(*) AS rx_volume,
	ROUND(AVG(TOTAL_REIMB),2) AS avg_reimbursement,
	ROUND(AVG(AAC),2) AS avg_aac,
	ROUND(AVG(NET_PROFIT),2) AS avg_net_profit,
	ROUND(AVG(TOTAL_REIMB) - AVG(AVG(TOTAL_REIMB)) OVER(),2) AS variance_from_avg,
	CASE
		WHEN ((AVG(AAC) * 1.05 + 1.75) - AVG(TOTAL_REIMB)) / AVG(TOTAL_REIMB) <= 0
		THEN 'No Increase Needed'
		ELSE CAST(ROUND(
			((AVG(AAC) * 1.05 + 1.75) - AVG(TOTAL_REIMB)) / AVG(TOTAL_REIMB)
			,4) AS VARCHAR(20))
		END AS rate_increase_needed_pct
FROM dbo.rx_claims
WHERE CLAIM_STATUS = 'PAID'
GROUP BY PAYER_NAME
ORDER BY avg_net_profit DESC