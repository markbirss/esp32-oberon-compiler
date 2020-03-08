/*GENERATED BY OBNC 0.16.1*/

#include <obnc/OBNC.h>

#define OBERON_SOURCE_FILENAME "Strings.Mod"

OBNC_INTEGER Length_(const char s_[], OBNC_INTEGER s_len)
{
	OBNC_INTEGER i_;

	i_ = 0;
	while ((i_ < s_len) && (s_[OBNC_IT(i_, s_len, 62)] != '\x00')) {
		OBNC_INC(i_);
	}
	return i_;
}


OBNC_INTEGER Write_(const char src_[], OBNC_INTEGER src_len, char dest_[], OBNC_INTEGER dest_len, OBNC_INTEGER at_)
{
	OBNC_INTEGER i_, ldest_, lsrc_;

	ldest_ = dest_len - 1;
	lsrc_ = src_len;
	if ((((at_ >= 0) && (ldest_ > 0)) && (lsrc_ > 0)) && (at_ < ldest_)) {
		i_ = 0;
		while (((at_ < ldest_) && (i_ < lsrc_)) && (src_[OBNC_IT(i_, src_len, 74)] != '\x00')) {
			dest_[OBNC_IT(at_, dest_len, 75)] = src_[OBNC_IT(i_, src_len, 75)];
			OBNC_INC(at_);
			OBNC_INC(i_);
		}
		dest_[OBNC_IT(at_, dest_len, 79)] = '\x00';
		if ((i_ < lsrc_) && (src_[OBNC_IT(i_, src_len, 80)] != '\x00')) {
			at_ = -1;
		}
	}
	else {
		at_ = -1;
	}
	return at_;
}


void Append_(const char extra_[], OBNC_INTEGER extra_len, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER n1_, n2_, i_;

	n1_ = Length_(dest_, dest_len);
	n2_ = Length_(extra_, extra_len);
	i_ = 0;
	while ((i_ < n2_) && ((i_ + n1_) < dest_len)) {
		dest_[OBNC_IT(i_ + n1_, dest_len, 90)] = extra_[OBNC_IT(i_, extra_len, 90)];
		OBNC_INC(i_);
	}
	if ((i_ + n1_) < dest_len) {
		dest_[OBNC_IT(i_ + n1_, dest_len, 91)] = '\x00';
	}
	else if (dest_len != 0) {
		dest_[OBNC_IT(dest_len - 1, dest_len, 92)] = '\x00';
	}
}


OBNC_INTEGER WriteChar_(char c_, char dest_[], OBNC_INTEGER dest_len, OBNC_INTEGER at_)
{

	if ((at_ >= 0) && ((at_ + 1) < dest_len)) {
		dest_[OBNC_IT(at_, dest_len, 98)] = c_;
		dest_[OBNC_IT(at_ + 1, dest_len, 99)] = '\x00';
		OBNC_INC(at_);
	}
	else {
		at_ = -1;
	}
	return at_;
}


void AppendChar_(char c_, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER i_;

	i_ = WriteChar_(c_, dest_, dest_len, Length_(dest_, dest_len));
}


OBNC_INTEGER WriteInt_(OBNC_INTEGER x_, OBNC_INTEGER n_, char dest_[], OBNC_INTEGER dest_len, OBNC_INTEGER at_)
{
	OBNC_INTEGER i_, size_, tot_, neg_;
	char a_[10];

	if (OBNC_ROR(x_, 31) == 1) {
		at_ = Write_(" -2147483648", 13, dest_, dest_len, at_);
	}
	else {
		i_ = 0;
		if (x_ < 0) {
			OBNC_DEC(n_);
			x_ = -x_;
			neg_ = 1;
		}
		else {
			neg_ = 0;
		}
		do {
			a_[OBNC_IT(i_, 10, 121)] = OBNC_CHR((OBNC_MOD(x_, 10)) + 48);
			x_ = OBNC_DIV(x_, 10);
			OBNC_INC(i_);
		} while (! (x_ == 0));
		size_ = dest_len;
		tot_ = (at_ + i_) + neg_;
		if (n_ >= i_) {
			tot_ = tot_ + (n_ - i_);
		}
		if ((at_ >= 0) && (tot_ < size_)) {
			while (n_ > i_) {
				dest_[OBNC_IT(at_, dest_len, 127)] = ' ';
				OBNC_DEC(n_);
				OBNC_INC(at_);
			}
			if (neg_ == 1) {
				dest_[OBNC_IT(at_, dest_len, 128)] = '-';
				OBNC_INC(at_);
			}
			do {
				OBNC_DEC(i_);
				dest_[OBNC_IT(at_, dest_len, 129)] = a_[OBNC_IT(i_, 10, 129)];
				OBNC_INC(at_);
			} while (! (i_ == 0));
			dest_[OBNC_IT(at_, dest_len, 130)] = '\x00';
		}
		else {
			at_ = -1;
		}
	}
	return at_;
}


void AppendInt_(OBNC_INTEGER x_, OBNC_INTEGER n_, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER i_;

	i_ = WriteInt_(x_, n_, dest_, dest_len, Length_(dest_, dest_len));
}


void Copy_(const char src_[], OBNC_INTEGER src_len, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER i_, ldest_, lsrc_;

	ldest_ = dest_len - 1;
	lsrc_ = src_len;
	if ((ldest_ > 0) && (lsrc_ > 0)) {
		i_ = 0;
		while (((i_ < ldest_) && (i_ < lsrc_)) && (src_[OBNC_IT(i_, src_len, 150)] != '\x00')) {
			dest_[OBNC_IT(i_, dest_len, 151)] = src_[OBNC_IT(i_, src_len, 151)];
			OBNC_INC(i_);
		}
		dest_[OBNC_IT(i_, dest_len, 154)] = '\x00';
	}
}


void Insert_(const char source_[], OBNC_INTEGER source_len, OBNC_INTEGER pos_, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER n1_, n2_, len_, i_, j_;

	n1_ = Length_(dest_, dest_len);
	n2_ = Length_(source_, source_len);
	len_ = dest_len;
	if (pos_ < 0) {
		pos_ = 0;
	}
	if (pos_ > n1_) {
		Append_(source_, source_len, dest_, dest_len);
	}
	else {
		if ((pos_ + n2_) < len_) {
			i_ = n1_;
			j_ = i_ + n2_;
			while (i_ >= pos_) {
				if (j_ < len_) {
					dest_[OBNC_IT(j_, dest_len, 170)] = dest_[OBNC_IT(i_, dest_len, 170)];
				}
				OBNC_DEC(i_);
				OBNC_DEC(j_);
			}
		}
		i_ = 0;
		j_ = pos_;
		while ((i_ < n2_) && (j_ < len_)) {
			dest_[OBNC_IT(j_, dest_len, 177)] = source_[OBNC_IT(i_, source_len, 177)];
			OBNC_INC(i_);
			OBNC_INC(j_);
		}
		if ((j_ >= len_) && (dest_len != 0)) {
			dest_[OBNC_IT(len_ - 1, dest_len, 180)] = '\x00';
		}
	}
}


void Delete_(char s_[], OBNC_INTEGER s_len, OBNC_INTEGER pos_, OBNC_INTEGER n_)
{
	OBNC_INTEGER len_, i_;

	len_ = Length_(s_, s_len);
	if (pos_ < len_) {
		if (pos_ < 0) {
			pos_ = 0;
		}
		if ((pos_ + n_) < len_) {
			i_ = pos_ + n_;
			while (i_ < len_) {
				s_[OBNC_IT(i_ - n_, s_len, 192)] = s_[OBNC_IT(i_, s_len, 192)];
				OBNC_INC(i_);
			}
			if ((i_ - n_) < s_len) {
				s_[OBNC_IT(i_ - n_, s_len, 193)] = '\x00';
			}
		}
		else if (s_len != 0) {
			s_[OBNC_IT(pos_, s_len, 194)] = '\x00';
		}
	}
}


void Replace_(const char source_[], OBNC_INTEGER source_len, OBNC_INTEGER pos_, char dest_[], OBNC_INTEGER dest_len)
{

	Delete_(dest_, dest_len, pos_, Length_(source_, source_len));
	Insert_(source_, source_len, pos_, dest_, dest_len);
}


void Extract_(const char source_[], OBNC_INTEGER source_len, OBNC_INTEGER pos_, OBNC_INTEGER n_, char dest_[], OBNC_INTEGER dest_len)
{
	OBNC_INTEGER len_, destLen_, i_;

	if ((dest_len != 0) && (source_len != 0)) {
		len_ = Length_(source_, source_len);
		destLen_ = dest_len - 1;
		if (pos_ < 0) {
			pos_ = 0;
		}
		if (pos_ >= len_) {
			dest_[OBNC_IT(0, dest_len, 215)] = '\x00';
		}
		else {
			i_ = 0;
			while ((((pos_ + i_) <= source_len) && (source_[OBNC_IT(pos_ + i_, source_len, 218)] != '\x00')) && (i_ < n_)) {
				if (i_ < destLen_) {
					dest_[OBNC_IT(i_, dest_len, 219)] = source_[OBNC_IT(pos_ + i_, source_len, 219)];
				}
				OBNC_INC(i_);
			}
			dest_[OBNC_IT(i_, dest_len, 222)] = '\x00';
		}
	}
}


OBNC_INTEGER Pos_(const char pattern_[], OBNC_INTEGER pattern_len, const char s_[], OBNC_INTEGER s_len, OBNC_INTEGER pos_)
{
	OBNC_INTEGER n1_, n2_, i_, j_, res_;
	int done_;

	n1_ = Length_(s_, s_len);
	n2_ = Length_(pattern_, pattern_len);
	if (n2_ == 0) {
		res_ = 0;
	}
	else {
		res_ = -1;
		done_ = 0;
		i_ = pos_;
		while ((! done_) && (i_ <= (n1_ - n2_))) {
			if (s_[OBNC_IT(i_, s_len, 238)] == pattern_[OBNC_IT(0, pattern_len, 238)]) {
				j_ = 1;
				while ((j_ < n2_) && (s_[OBNC_IT(i_ + j_, s_len, 239)] == pattern_[OBNC_IT(j_, pattern_len, 239)])) {
					OBNC_INC(j_);
				}
				if (j_ == n2_) {
					res_ = i_;
					done_ = 1;
				}
			}
			OBNC_INC(i_);
		}
	}
	return res_;
}


void Cap_(char s_[], OBNC_INTEGER s_len)
{
	OBNC_INTEGER i_;

	if (s_len != 0) {
		i_ = 0;
		while (s_[OBNC_IT(i_, s_len, 254)] != '\x00') {
			if (((unsigned char) 'a' <= (unsigned char) s_[OBNC_IT(i_, s_len, 255)]) && ((unsigned char) s_[OBNC_IT(i_, s_len, 255)] <= (unsigned char) 'z')) {
				s_[OBNC_IT(i_, s_len, 256)] = OBNC_CHR((OBNC_ORD((unsigned char) (s_[OBNC_IT(i_, s_len, 256)])) - 97) + 65);
			}
			OBNC_INC(i_);
		}
	}
}


int Match_(const char string_[], OBNC_INTEGER string_len, const char pattern_[], OBNC_INTEGER pattern_len);

static int Match_M_Local(const char name_[], OBNC_INTEGER name_len, const char mask_[], OBNC_INTEGER mask_len, OBNC_INTEGER n_, OBNC_INTEGER m_)
{
	int res_;

	res_ = 1;
	while (((n_ >= 0) && (m_ >= 0)) && (mask_[OBNC_IT(m_, mask_len, 270)] != '*')) {
		if (name_[OBNC_IT(n_, name_len, 271)] != mask_[OBNC_IT(m_, mask_len, 271)]) {
			res_ = 0;
			n_ = 0;
		}
		OBNC_DEC(n_);
		OBNC_DEC(m_);
	}
	if (res_) {
		res_ = 0;
		if (m_ < 0) {
			res_ = n_ < 0;
		}
		else {
			while ((m_ >= 0) && (mask_[OBNC_IT(m_, mask_len, 280)] == '*')) {
				OBNC_DEC(m_);
			}
			if (m_ < 0) {
				res_ = 1;
			}
			else {
				while (n_ >= 0) {
					if (Match_M_Local(name_, name_len, mask_, mask_len, n_, m_)) {
						res_ = 1;
						n_ = 0;
					}
					OBNC_DEC(n_);
				}
			}
		}
	}
	return res_;
}


int Match_(const char string_[], OBNC_INTEGER string_len, const char pattern_[], OBNC_INTEGER pattern_len)
{
	return Match_M_Local(string_, string_len, pattern_, pattern_len, (Length_(string_, string_len) - 1), (Length_(pattern_, pattern_len) - 1));
}


#if OBNC_CONFIG_TARGET_EMB
int main(void)
{
	OBNC_Init(0, NULL);
#else
int main(int argc, char *argv[])
{
	OBNC_Init(argc, argv);
#endif
	return 0;
}