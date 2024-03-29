select
yt_channel_id as "YT Channel ID"
, title as "Title"
, date_trunc('month',modified) as "Month"
, date_trunc('quarter',modified) as "Quarter"
, date_trunc('hour', date_trunc('quarter',modified)) as "Quarter Hour"
, max(subscribers) as "Subscribers"
, max(total_views) as "Total Views"

from thresher.yt_channel_history

where modified  >= '2018-01-01'
and yt_channel_id in (
'UCWiY11X3QxUA_usUTdgPb-A',
'UCEMXqjjzweSO0-yRMvFD7rQ',
'UCuSpKLpxklSooAxlZU8hW2w',
'UClOcjfF7fxejYmKPXG8us5A',
'UC2HUr0g_P93BkSANRcQ12_A',
'UCiStVUCJYuR1kKzc-GvksPQ',
'UCwhnjrRM9zin-Jl3ji21u9A',
'UCTIlWlOnLJtHo5R02sxMsKg',
'UCbqPBFR7WMsvYl4t-_q91Yw',
'UC1i4OA0FdWSavk5vumCKFJw',
'UCvv57du6MlCXERa9ct-c-DQ',
'UCvhFrIsIyxsEqJY62y3DTKA',
'UCOCDJuKH6HZdRUqK6QTxGBg',
'UCnUuzwcTFpYfwJ4gPXI0jaw',
'UCO2F8YKi2iEaTK_6m5qUjYA',
'UCfvdDVVPpCEFdmlqITRp8jA',
'UCNBSX1hc45orvpONETi1BVQ',
'UCwZPHTeedmYdkErTLy6ahrA',
'UC4Yb5KGvyijcAz-vdAa2TNQ',
'UCGJSMeQ62TujzHg1RW7ER7A',
'UChcYWdGGh7OMLjHTJLhCWTg',
'UCyfyXhr51B8pgUUzXkFCV1w',
'UC0Y3NaYeIdDVDse6gM12irg',
'UCF7EMSMocVtWbAwLtzsY8EA',
'UCJBwRJnyNLV8dEdF2fdIH-A',
'UC1nEjLYLOkTF0EEQjbwxCqA',
'UCXQMGHlZPl3oxHK_u1IkawA',
'UCvwr8zx3cLNdNlT-eLXY1SQ',
'UC4_KRggmX_xuZv8HqCohnHQ',
'UCpboSvHMycSUa3-zU7NLh3A',
'UCg249XAkPjeywkL12ld0Dzw',
'UCmmUuRo60lmO8-3-meKu21Q',
'UC97cZsOCVufvmRXvLusdj2Q',
'UC1wIwDgFvs8DZT5knoLHHhA',
'UCWwcM2RJAt0IXmWlveXpLLw',
'UCGk6L9O0jVOXvaDek63Z-BQ',
'UCwS56keVzmE-qPlF_4Y3-SA',
'UC4NmXvKktaxogNHCzwoqCnQ',
'UC7q9VFij8uhzaan6woBWQjw',
'UCw7aeTxfJ4aP8REx8SMZQxQ',
'UC5AngbC7w3patkjY8ma8zZA',
'UCYWIgiRCxF0EsDZGxcpKArQ',
'UC-xqHIwo_AtsKITF2N1Be-A',
'UC6iYg0lVIs_c-LJyuDBIPEA',
'UCM4JOBuM5DK2XCa-PifByEg',
'UClsPl8aFXSkdoYVQu1ipxMg',
'UCAWq4v6tDRqBvbdX5CpBVLA',
'UCxeBIoLvY8Z-HUwlbbg1wNA',
'UCclHSnngVTZK7LEOQAzcg1w',
'UCi0o9irT_KUpHmACT2VLiwg',
'UC28GaC7PWKfziN3d6GlgOUA',
'UChlp139Pw3Y2kD1F5TT6Hgg',
'UCIlyowg3Qc_WI4S6qRewgyA',
'UCd_Iak5cYhhqMVgMWcS97kA',
'UCp13rYPp2O_fXExoMjuYe_A',
'UCePVC7mAyndAsDIvAUc6hWQ',
'UC9s3fTbShEZIP1yXNM6I7xg',
'UC8MupHwlZULY0RH1BxNwKsg',
'UC11OY9uVMrrw5hyzrYMzHvw',
'UCOD8EZ6ztG7mvv4-YSBR2Xg',
'UCAq9zYCfHy6E29jVq2Bee2Q',
'UC-5LNANFKTC1DOkuhbeq6OQ',
'UCoqk12_JfbCDhV9nNFsUSnA',
'UCroaCM5cpLKlcYzwe1DGR3A',
'UCNj6RRnM9vlHrxwgvTx80aw',
'UCbSXVsGkQ0cL_san7Qx4Crw',
'UCIxs-F-tBIbPE1KSxx3nckw',
'UCVngSTf80F1RQYsJAynx9zA',
'UCD11RY7UCKHpKKDVqV9Q_Lg',
'UCG1ZO0Y-86OG12gwn6WmIRA',
'UCzh02PAYzH0NG1VVKfCw5gg',
'UCGLHYdHBdGICq1Kh-7WXuDw',
'UCAU6OZfj5QsskYK0Q4GU0oA',
'UCi28MBKzvsivZi3D7EHtGcg',
'UCI7S4hsaSZHKWS_5aKR2GEg',
'UCnsNsFAFPvFwpbaHJf2JtCQ',
'UC0uGC_EBwAxw3ljqeGjy2qw',
'UC1PUWbUS4moL4UA-67pmV7w',
'UCfx2fE2xdGj8l2jiiMMXCTw',
'UCzKJHZ4VMY-VvBZvK4t2o1g',
'UC_t1e6tr149-iDEEgFL8CHg',
'UCUxi5rvuPrADPD_hFhaAKVg',
'UCKfsyC4xq65Pxd8vxj2OLtA',
'UC0G_w1l-cJQRR1wAkmBkrAA',
'UCYBe3cPCbjUManWo2Mg8tNg',
'UCipEWAoj82m2jap3t_flXWA',
'UCzunjiZ-N4bkjU79AkNddQQ',
'UCwlG01E05JFQ2Zdz0_kgH6Q',
'UCdpmV6nRCMyD4HaMZjxBLgw',
'UCXwij3eG8vx42vBg9t0yPug',
'UCxwZnmLwSvrp1RjHNNeAeFQ',
'UCvZ03OvqcBZer6kP0mKLZgA',
'UCPAGrc_SLO-Mp_EcyFkxnRQ',
'UCK-OifcIYOPinClPLh74ppw',
'UCpUtw05HjLFcI5PO6eLusOg',
'UCLpgLnRZLaoggPxDuba91HQ',
'UC0HVR9T6oFS3veefhGCGEsw',
'UCsxPsPgGjaqlDGrRTvzHL4w',
'UCsaa2UmmGCM8HXVI1NTLbHQ',
'UCUvHjK2rYwCylZcHHSp0y2w',
'UC-mmJVBPMxSYAa4UVkLf3QQ',
'UCOedsFQ4mpPy4zTx9-cKugw',
'UC4tbMiRD7D-6f2XvrtqFHZw',
'UCucY8BDTc-QeTD9w-fklh_g',
'UCxR6Ke-sbUlmE0kqev5WHQw',
'UCgTDRn3iifHYkNfbwByWaQg',
'UCsP9PP0eLuIspLpW67XyVow',
'UCpmq5Vaz8uoDqT6XJFgafrA',
'UCg17mivnAaXprAdgCgpWNBg',
'UCF7kf0sOOgmYN03SHpmMUxQ',
'UCeHcEArSCMt-0vB47KaahQQ',
'UCjRNVnFc4NEYR9M5YCTpQ7w',
'UCN8vYf-Duv_Or0G09TBauvQ',
'UCQNiJG6kplgMXfNIXOe5WVw',
'UCET9U8nTqSmOQ-fRn8hYKww',
'UCnGyXMrQe979GrRtzXkBawQ',
'UCD-iKv5exBq27cnpyKpV9tA',
'UCZ6H6Upgtu5QrMZcSGersfg',
'UC2YoBgE5RQZmOmnZLj2aKcw',
'UC38o6-5irs2psAz_dofu1CQ',
'UC7w_mAZMyEwAWA1lu4JIczg',
'UCz-6zJvcSZoXbK_PoC_QM0g',
'UC21YW4ICr0LateQYNiM-tzQ',
'UCYgZAzY47sq7em40oCMJvqw',
'UCWfKE1pxWeZwlh68e8ZjwwA',
'UCYHmblcOeEvYWs-9sKRzxdg',
'UCNcGGgffE-_hUgSEWmaoY9A',
'UCCYjMsdaB0qtZrMvtgMIHPA',
'UCpk73wmZqKGXCIbidi7RWDw',
'UCi7EQKEM2zFm6T_3nba3JSw',
'UCU2ACt2gy77iJAZq46Uzqkw',
'UCzkaa0tWfVZDxaNfKDnEMsQ',
'UCOAivX4hehwYpTxSX6sHarQ',
'UCKYf9tk2zzRQwFCmTm8FU9Q',
'UCHC42Ely-vIjQvvJ4s8EaLQ',
'UCIlMA3Xa4Kw9dLmD1nHiAIg',
'UC5J5EtyE-EW29H7eEQeKqrA',
'UC5d4XRgWE4ddt5G9_jUuRKA',
'UCXBGxxRr3e46MReMrJimvuQ',
'UC6j-xSPNA3BC5vQb-zcmfEA',
'UCEon3JIAONQQMhrfxgonWBw',
'UCpre6PJTxxVF_13ZBtAz5_A',
'UCiuDD3t3PGJOO5pX5PCaTXQ',
'UCmDteXe3ClJ7Q0Fd0wsC6Lg',
'UCKSxuci1E2vaZrbr7lM_OOg',
'UCpczpglMZhRwTqqsGxyfHLg',
'UCDKNGKpzcfzYTv-Y6iQp-ow',
'UCtdeQembFu7N4QYbJdPqrEw',
'UCFRmOMxpQucUJIg4oPuv8eA',
'UCNavI7VPbI3Nx5pCTHFv_1g',
'UC9MCq-Yl3C_ceGL28lQkYlQ',
'UCoC8wK7Hbj1saQUBlFVaJkA',
'UCLIBDZCXcfFLeuaEz7_Uadg',
'UCxC_8pkeWXcrfptaNnneWrQ',
'UCxdXnyMQvvl8xkasBsE09yg',
'UCCOzdUNOMecNW6aSGZ64pQw',
'UCJqcphJAnsD5YDXcRFzTsOw',
'UC9EwwCBwzWhGGlNJujnnnRA',
'UC9cqIKwZhaZjrg9zy6EW-WA',
'UCWOfXptCir2Ub7eGEmABDWw',
'UCxIY2HU9DOsZeiAdboBE4NA',
'UCE1BqH-72EBs-siTbDAjOGQ',
'UC2F1sv6Lfz92_BQeNgRA4HQ',
'UCjN5-2-Vv7Bd4l5KokpNVUQ',
'UCWuWffRIfISx8mUNpqYDEdQ',
'UCqJodYzqJV__Ghv4OO6G8xw',
'UCWmhWIPAM_pOe0jjdYGTQSg',
'UCZDCBjTEpbzSOjUd2Xm5dyw',
'UCVFZ_4nIov0PSob9mQ2CUbA',
'UCpSgbQRNDe053TAuM0XQIXQ',
'UC9iozQVKe6uJE9-sB5A2zjg',
'UCUbJB5gjStcY2p9DBC7GLSQ',
'UCuXSDVyFgS_DL1EI4RJkBgg',
'UCq7EY7H2XF6TV7Z5mLv-aNg',
'UCydDJhHsXbPfVApThIc7Y6w',
'UCWZTQLvNSm92fZPnjVGFRIA',
'UC9Gnn2zUZ8R9IyyrkNdIC4w',
'UCZeYuwBrLCYDZZM5ibwhOiw',
'UCII3I1YkymcM7z2JivhR_Zg',
'UC7oql7D4nRZ5Nt7-1keEv9g',
'UC1WEyyN4YE9qG62lKskB1BQ',
'UCM4NhgWqcrL5LckyKyxTDIQ',
'UCtnTyKByadWKpcIUhXQC6YQ',
'UC2aqX7neep76msdg7W5N_Vw',
'UCMTthO3bsOTOwTJtkBZerVQ',
'UCIm-j1LiX1a1YIwfIcGe4Tw',
'UCNGr_3LSXp3KL55jZW7Pvhg',
'UCXnnace0s8keXKOOTFn53pg',
'UCPpVro_WUDDaifG_83BFnNQ',
'UCBaE6gbkXeUD-Hiv6a8qgAQ',
'UC9-bmjay5PBCYSXc9ISr7zw',
'UCJsbGHojKN7umW3QO9p5sdg',
'UCPu-PxgTekWg3_UoW40Kesw',
'UCZA5gPCu20UpNS3UfURGJVQ',
'UCx4287tWK7d49swYs7siHkQ',
'UCAXQSfPXCHMSh-BSkguh3kw',
'UC8L5zNuGdVs6rHy5X8uSLAg',
'UCw4yMx2iOcgycZlp_ydHTYw',
'UCbJCIZWDTxr4KySmOfZ_zow',
'UCqCeOg5R5gCSgf7mriXXlhQ',
'UCZ1CQE5_gNdcuvxwcZOahzA',
'UClJzRMlDe21tzf4BkmYJSgg',
'UCHYwNgHy2hp41uweb2Z0IDw',
'UCys909uk7s7BBTayLcemIiw',
'UCq35S-mp-LvmR0dzkESOhqw',
'UC5Ko2SVHM2iYkxpdfyA1ySA',
'UCWNYRPp3Z853cFtpUMdLsSg',
'UC9M9Xc8LCrJgn6zX5w8HKTQ',
'UCUy-7Ivz4DnxvD-M8sCljgA',
'UC3mwQsouFxbgWIVW0iEC2iQ',
'UChEB3k_QsuXrwthTaishT0g',
'UCmAkPaNe86WAuzep2zBgW2g',
'UCPeQYiEUH2lH_19gstisTWA',
'UCLHRWoQRaB-NwFIsVe_pDpA',
'UCpZQoj6f-6N7gj-yHvYVxpA',
'UCxbojRXni76CIInPEbjqTEA',
'UC3wxb6QDAvDZ4s-aflmLTuA',
'UCCbPcLpRLWMrj5KFKk9Zanw',
'UC-O8OH1H97oRlkPrvLAShaA',
'UCD_fzuAI35b_6RpcOQ2HlSg',
'UC8Lct4xNsxF4shq3PP_Dczg',
'UC5sIrqjvZLPO5Dj3Jpa2T6Q',
'UCtlLnHSvpUVwuRiZT8XLtNA',
'UCe-9xxsP1m7_rC_K5LVqQeQ',
'UCDeQo_d2P0XuAXVCHWnIKWA',
'UCVjyR2zoYEPY_U0bLIrezew',
'UCKk7IzvX_SfKJOfoyxPkbXg',
'UC1pR2mHMDXXf1QjtIlHD6ww',
'UCXGVsie-SIk3e3wJmUTyEhw',
'UCXO0g55lwxInR3HWg7kfOuw',
'UCQsApRFJt3FbS8yF-ToOItw',
'UCSQ5chcdI3Um1e11hnffJTw',
'UC3Ae7eKZZXt9_22qIWRIodg',
'UCXkdQd8Nnbmq8OCipfQyfcQ',
'UCUo-VDQf7V6ZOhkWIMh0OdQ',
'UC0mK_iz6_6YibzzwtlYOXAQ',
'UCunDAp8XEvSbbRImnL__Iww',
'UCV6ZteBTfCbN9CBdDeMDh3g',
'UCUs0ADQl9M9NrVX0JyBfH3A',
'UCyItP8QU4s2LrXERR1D1j7g',
'UCTUsCFCgSjtlkmjQjbpMkNw',
'UC2_NoH96vBrJ4Q3Qqo2_kYw',
'UCJGXznJ7SO3LZSznYZMSpHw',
'UCyFB1qFyzdQQ9utG2FG0Jcw',
'UCaj8zgR2-szGWQuDi0dJRIA',
'UCumysICHHAn9flu3dvu1dhQ',
'UCO4J45wBpvjnbYQWlxp7nmg',
'UCSh1i0qIVPvmlt0zKjzSp-g',
'UCZiNyg1S02U8fZPKFoXtDug',
'UCVdIrB4R1bVH1j57Bmo7vAQ',
'UCAgs3pFGzAbOaaZuQwspQgw',
'UCu49-B9D5Be4s2EMoGsiEkQ',
'UCrtfuhji3_wGUedOS1CYSdg',
'UCYcWOa0t0a_fACzUh1hnLiA',
'UCxpo7DZaZN1f39WiWbetDRw',
'UCQCxhaQQ0oQwMtkPOof9Adg',
'UC0b0iQqr2Scbjgsm1t6YfyA',
'UCI5Bz9zMQyz8uv6bkgxVacA',
'UCBJH3OjsM_lXOHbMXwHH8QA',
'UCuwfD4ch7JFGQHDYv-rYlkw',
'UCrAIMqvf7X540mIDLaVolng',
'UCslfzwJAXnw1XdAcpDJTjFQ',
'UCDHSXlDCzFcTCd-gunU87yg',
'UCbjqZK5wP_8MG79Pkf-mc7w',
'UCyFbq_XGXsCaz6lP3z8HvCQ',
'UCfWgmHBwEu-AoFy2spGQdpQ',
'UC7m6VekAbd1p9XdlsUgc8-g',
'UCi7nMpXuCXT_SUOOE6Yy2ag',
'UCSsBwMlXvtJvhf8N9aVNMDQ',
'UCj28gEwD-ZicKaUOo76tsxg',
'UCLZ1HKsITwfIRqJOJPI5y7Q',
'UCcg1awKGH0fIVJnWUK5HsYg',
'UCp5lRKP0SQivNrBStmCvJog',
'UCFitySJyD932WXmrwEjmtvg',
'UCHDJB1q_JcWKLm_b-I07CQg',
'UCHkaVHdFbo4R_3Z_CkjuVnA',
'UCjb9zA52j7J8c3qe8pB57rQ',
'UCOGkONOjXhxTgpqCiZ4EY7w',
'UCKvRT5Jl1ybJQZwhoiERN-A',
'UCYvDCeivfpQuUOB07P2YDBQ',
'UCORCus9Bpkh_26AMHcG1d8Q',
'UCNVO80OXDb-a8EkiRnfNSUg',
'UCpQ-23z7n9gVIuh30nMpCmg',
'UC0eRzp5O6xQbkJcUBSrUsug',
'UC8DjZQBSDNJ_ZFhh37i2vxA',
'UCYcEulviBePo73G9mT6vBUA',
'UC2MhJT_Xogab9QMFNs2i99g',
'UCUD_Qyy6pjmiLG7xCx0tmuQ',
'UCvQaGPS5dA9-QPmjlBbKvWA'
)

group by 
yt_channel_id
, title
, "Month"
, "Quarter"