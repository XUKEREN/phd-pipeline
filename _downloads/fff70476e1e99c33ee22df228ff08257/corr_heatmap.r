# Correlation heatmap between smoking variables

smoking_var <- df_B %>%
    select(c(
        "f_ever_sm_di", "f_sm_now_di", "f_sm_pre_di",
        "f_cignumpre", "m_ever_sm_di", "m_sm_now_di", "m_sm_pre_di",
        "m_cignumpre", "m_sm_preg_di", "m_cignumpreg", "m_sm_bf_di",
        "m_cignum_bf", "m_sm_post_di", "m_cignum_post", "ch_shs_othsm_indoor",
        "ch_shs_parent", "ch_shs", "cumulative_smoking_score_cont", "m_sm_prenatal_di", "m_cignumprenatal", "AHRR_negative10", "Methylation_score"
    )) %>%
    rename(
        "Paternal, ever" = "f_ever_sm_di", "Paternal, now" = "f_sm_now_di", "Paternal, preconception" = "f_sm_pre_di", "Paternal, preconception (CPD)" = "f_cignumpre", "Maternal, ever" = "m_ever_sm_di", "Maternal, now" = "m_sm_now_di", "Maternal, preconception" = "m_sm_pre_di",
        "Maternal, preconception (CPD)" = "m_cignumpre", "Maternal, pregnancy" = "m_sm_preg_di", "Maternal, pregnancy (CPD)" = "m_cignumpreg", "Maternal, breastfeeding" = "m_sm_bf_di",
        "Maternal, breastfeeding (CPD)" = "m_cignum_bf", "Maternal, postnatal" = "m_sm_post_di", "Maternal, postnatal (CPD)" = "m_cignum_post", "Child, postnatal passive (other)" = "ch_shs_othsm_indoor",
        "Child, postnatal passive (parent)" = "ch_shs_parent", "Child, postnatal passive" = "ch_shs", "Cumulative exposures" = "cumulative_smoking_score_cont", "Maternal, prenatal" = "m_sm_prenatal_di", "Maternal, prenatal (CPD)" = "m_cignumprenatal", "AHRR cg05575921 methylation (-0.1beta)" = "AHRR_negative10", "Polyepigenetic smoking score" = "Methylation_score"
    )


f1 <- function(x) {
    if (is.factor(x)) as.numeric(x) else x
}

smoking_var <- smoking_var %>% map_dfr(~ f1(.x))

correlation_matrix <- cor(smoking_var, method = "spearman", use = "pairwise.complete.obs")

library(Hmisc)
res <- rcorr(as.matrix(smoking_var), type = "spearman")

# a simple function to format the correlation matrix
flattenCorrMatrix <- function(cormat, pmat) {
    ut <- upper.tri(cormat)
    data.frame(
        row = rownames(cormat)[row(cormat)[ut]],
        column = rownames(cormat)[col(cormat)[ut]],
        cor = (cormat)[ut],
        p = pmat[ut]
    )
}

kable(flattenCorrMatrix(res$r, res$P), caption = "spearman correlation test for smoking variables")


res_p <- flattenCorrMatrix(res$r, res$P)

library(wesanderson)
pal <- wes_palette("Zissou1", 100, type = "continuous")

library(reshape2)
cormat <- round(correlation_matrix, 2)
melted_cormat <- melt(cormat)

# Get lower triangle of the correlation matrix
get_lower_tri <- function(cormat) {
    cormat[upper.tri(cormat)] <- NA
    return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat) {
    cormat[lower.tri(cormat)] <- NA
    return(cormat)
}

upper_tri <- get_upper_tri(cormat)

res_p_1 <- res_p %>% rename(Var1 = row, Var2 = column)
res_p_2 <- res_p %>% rename(Var2 = row, Var1 = column)

# Melt the correlation matrix
library(reshape2)
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Heatmap

reorder_cormat <- function(cormat) {
    # Use correlation between variables as distance
    dd <- as.dist((1 - cormat) / 2)
    hc <- hclust(dd)
    cormat <- cormat[hc$order, hc$order]
}
# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)

dat_p.val <- melted_cormat %>%
    left_join(res_p_1, c("Var1", "Var2")) %>%
    left_join(res_p_2, c("Var1", "Var2")) %>%
    mutate(p.value = ifelse(is.na(p.x), p.y, p.x)) %>%
    select(Var1, Var2, value, p.value) %>%
    filter(!is.na(p.value))

# Create a ggheatmap

melted_cormat <- melted_cormat %>% filter(Var2 != Var1)

ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value)) +
    geom_tile(color = "white") +
    scale_fill_gradientn(
        colours = pal,
        values = rescale(c(-0.03, 0.5, 1)), limit = c(-0.03, 1), space = "Lab",
        name = "Correlation"
    ) +
    theme_minimal() + # minimal theme
    theme(axis.text.x = element_text(angle = 45, hjust = 1), axis.text.y = element_text(angle = 0, hjust = 1)) +
    coord_fixed() +
    scale_x_discrete(expand = c(0, 0)) +
    scale_y_discrete(expand = c(0, 0)) +
    coord_equal()

dat_p.val[dat_p.val$p.value > 0.05, ]

ggheatmap +
    geom_text(aes(dat_p.val$Var2, dat_p.val$Var1, label = paste(format(melted_cormat$value, 2), c(" ", "*")[(abs(dat_p.val$p.value) <= .05) + 1])), color = "black", size = 2.5, angle = 0) +
    theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.major = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        axis.ticks = element_blank(),
        legend.justification = c(1, 0),
        legend.position = c(0.6, 0.7),
        legend.direction = "horizontal",
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.text.y = element_text(angle = 0, hjust = 1)
    ) +
    guides(fill = guide_colorbar(
        barwidth = 7, barheight = 1,
        title.position = "top", title.hjust = 0.5, title = "EPIC\nSpearman Correlation"
    )) + scale_y_discrete(position = "right")
